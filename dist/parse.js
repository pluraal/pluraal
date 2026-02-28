import { readFile } from "fs/promises";
import { unified } from "unified";
import remarkParse from "remark-parse";
import remarkGfm from "remark-gfm";
// ---------------------------------------------------------------------------
// AST helpers
// ---------------------------------------------------------------------------
function isHeading(node, depth) {
    return node.type === "heading" && node.depth === depth;
}
function isList(node) {
    return node.type === "list";
}
function isTable(node) {
    return node.type === "table";
}
/** Extract plain text from an AST node's children (headings, cells, etc.). */
function nodeText(node) {
    const parts = [];
    function walk(n) {
        if ("value" in n && typeof n.value === "string") {
            parts.push(n.value);
        }
        if (n.children) {
            for (const child of n.children) {
                walk(child);
            }
        }
    }
    walk(node);
    return parts.join("").trim();
}
// ---------------------------------------------------------------------------
// Expression parsing
// ---------------------------------------------------------------------------
function parseListItemExpr(item) {
    // A ListItem has:
    //   children[0]  — Paragraph with the expression content (link | inlineCode | text)
    //   children[1]? — nested List with arguments
    const para = item.children[0];
    if (!para || para.type !== "paragraph") {
        throw new Error("Expected paragraph as first child of list item");
    }
    const p = para;
    const nestedList = item.children[1];
    const args = nestedList && isList(nestedList)
        ? nestedList.children.map(parseListItemExpr)
        : [];
    const first = p.children[0];
    if (first.type === "link") {
        const link = first;
        return { kind: "call", op: link.url, args };
    }
    if (first.type === "inlineCode") {
        const raw = first.value.trim();
        return parseScalar(raw);
    }
    if (first.type === "text") {
        const raw = first.value.trim();
        return parseScalar(raw);
    }
    throw new Error(`Unexpected list item content type: ${first.type}`);
}
function parseScalar(raw) {
    if (raw === "true")
        return { kind: "literal", value: true };
    if (raw === "false")
        return { kind: "literal", value: false };
    const num = Number(raw);
    if (!isNaN(num) && raw !== "")
        return { kind: "literal", value: num };
    return { kind: "var", name: raw };
}
function parseExprFromList(list) {
    if (list.children.length === 0) {
        throw new Error("Expression list is empty");
    }
    // The top-level list should have exactly one root expression item.
    // (Multiple items would be ambiguous; spec always uses one root.)
    return parseListItemExpr(list.children[0]);
}
// ---------------------------------------------------------------------------
// Test-case table parsing
// ---------------------------------------------------------------------------
function parseCellValue(raw) {
    if (raw === "true")
        return true;
    if (raw === "false")
        return false;
    const num = Number(raw);
    if (!isNaN(num) && raw !== "")
        return num;
    return raw;
}
function parseTestCases(table, definitionName) {
    if (table.children.length < 2)
        return [];
    const headerRow = table.children[0];
    const headers = headerRow.children.map((cell) => {
        const text = nodeText(cell)
            .replace(/^`|`$/g, "")
            .trim();
        return text;
    });
    // Last column is the expected output; the rest are inputs.
    const inputHeaders = headers.slice(0, -1);
    const outputHeader = headers[headers.length - 1];
    // Validate: the output column should match the definition name.
    if (outputHeader !== definitionName) {
        // Some tables use generic names (Input A/B, Output) — still parse them.
        // We accept any table found under a "Test cases" heading.
    }
    return table.children.slice(1).map((row) => {
        const cells = row.children.map((cell) => parseCellValue(nodeText(cell)
            .replace(/^`|`$/g, "")
            .trim()));
        const inputs = {};
        for (let i = 0; i < inputHeaders.length; i++) {
            inputs[inputHeaders[i]] = cells[i];
        }
        const expected = cells[cells.length - 1];
        return { inputs, expected };
    });
}
// ---------------------------------------------------------------------------
// Section walking
// ---------------------------------------------------------------------------
function parseDefinition(nodes, startIndex) {
    const headingNode = nodes[startIndex];
    const rawName = nodeText(headingNode);
    // Strip surrounding backticks if present, e.g. `subtotal` → subtotal
    const name = rawName.replace(/^`|`$/g, "");
    let expr = null;
    let testCases = [];
    let i = startIndex + 1;
    let inTestCases = false;
    while (i < nodes.length) {
        const node = nodes[i];
        // Stop when we hit another h3 or higher-level heading (exits this definition)
        if (node.type === "heading" && node.depth <= 3) {
            break;
        }
        // h4 heading signals a subsection
        if (node.type === "heading" && node.depth === 4) {
            const h4Text = nodeText(node).toLowerCase();
            inTestCases = h4Text === "test cases";
            i++;
            continue;
        }
        if (isList(node) && !inTestCases && expr === null) {
            // First list in the definition body is the expression.
            expr = parseExprFromList(node);
            i++;
            continue;
        }
        if (isTable(node) && inTestCases) {
            testCases = parseTestCases(node, name);
            i++;
            continue;
        }
        i++;
    }
    if (expr === null) {
        throw new Error(`Definition "${name}" has no expression list`);
    }
    return {
        definition: { name, expr, testCases },
        nextIndex: i,
    };
}
// ---------------------------------------------------------------------------
// Top-level module parse
// ---------------------------------------------------------------------------
export async function parseUserModule(filePath) {
    const source = await readFile(filePath, "utf8");
    const processor = unified().use(remarkParse).use(remarkGfm);
    const root = processor.parse(source);
    const nodes = root.children;
    let title = "";
    const inputs = [];
    const definitions = [];
    let i = 0;
    // Extract h1 title.
    if (i < nodes.length && isHeading(nodes[i], 1)) {
        title = nodeText(nodes[i]);
        i++;
    }
    let currentSection = "";
    while (i < nodes.length) {
        const node = nodes[i];
        if (isHeading(node, 2)) {
            currentSection = nodeText(node).toLowerCase();
            i++;
            continue;
        }
        // Under "Inputs" section: parse the bullet list of input names.
        if (currentSection === "inputs" && isList(node)) {
            for (const item of node.children) {
                const text = nodeText(item);
                // Format: "`name` — description"
                const nameMatch = text.match(/^`?([^`\s—]+)`?\s*(?:—|$)/);
                if (nameMatch)
                    inputs.push(nameMatch[1]);
            }
            i++;
            continue;
        }
        // Under "Definitions" or "Validations" or any h2 section: parse h3 definitions.
        if (isHeading(node, 3)) {
            const { definition, nextIndex } = parseDefinition(nodes, i);
            definitions.push(definition);
            i = nextIndex;
            continue;
        }
        i++;
    }
    return { title, inputs, definitions };
}
//# sourceMappingURL=parse.js.map