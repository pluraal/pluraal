import type { List, ListItem, Paragraph, Link, PhrasingContent } from "mdast";

/**
 * Recognized If-Then-Else structure extracted from the mdast AST.
 *
 * Pattern: a list whose single listItem has:
 *   1. A paragraph containing a link whose URL ends with
 *      "language/boolean.md#if-then-else"
 *   2. A nested list with exactly 3 items:
 *      - condition (arg 0)
 *      - then-value (arg 1)
 *      - else-value (arg 2)
 */
export interface IfThenElsePattern {
  /** The display text of the operation link (e.g. "If-Then-Else"). */
  operationLabel: string;
  /** The URL the operation link points to. */
  operationUrl: string;
  /** Inline content nodes for the condition argument. */
  condition: PhrasingContent[];
  /** Inline content nodes for the "then" branch value. */
  thenBranch: PhrasingContent[];
  /** Inline content nodes for the "else" branch value. */
  elseBranch: PhrasingContent[];
}

const IF_THEN_ELSE_SUFFIX = "language/boolean.md#if-then-else";

/**
 * Attempt to match a `list` node against the If-Then-Else pattern.
 * Returns the extracted structure on success, or `null` if the node
 * does not match.
 */
export function matchIfThenElse(node: List): IfThenElsePattern | null {
  // Must be a single-item unordered list
  if (node.ordered || node.children.length !== 1) return null;

  const item: ListItem = node.children[0];

  // The listItem must have exactly 2 children: a paragraph and a nested list
  if (item.children.length !== 2) return null;

  const [first, second] = item.children;
  if (first.type !== "paragraph" || second.type !== "list") return null;

  const para = first as Paragraph;
  const argList = second as List;

  // The paragraph must contain a link whose URL ends with the sentinel
  const link = findIfThenElseLink(para);
  if (!link) return null;

  // The nested list must have exactly 3 items (condition, then, else)
  if (argList.children.length !== 3) return null;

  const args = argList.children.map(extractInlineContent);
  if (args.some((a) => a === null)) return null;

  return {
    operationLabel: extractLinkText(link),
    operationUrl: link.url,
    condition: args[0]!,
    thenBranch: args[1]!,
    elseBranch: args[2]!,
  };
}

/** Find a link ending with the If-Then-Else URL suffix inside a paragraph. */
function findIfThenElseLink(para: Paragraph): Link | null {
  for (const child of para.children) {
    if (child.type === "link" && child.url.endsWith(IF_THEN_ELSE_SUFFIX)) {
      return child;
    }
  }
  return null;
}

/** Extract plain text from a link node's children. */
function extractLinkText(link: Link): string {
  return link.children
    .map((c) => ("value" in c ? (c as { value: string }).value : ""))
    .join("");
}

/**
 * Extract the inline (phrasing) content from a listItem.
 * Expects the listItem to contain a single paragraph whose children
 * are the phrasing content we want.
 */
function extractInlineContent(li: ListItem): PhrasingContent[] | null {
  if (li.children.length !== 1) return null;
  const child = li.children[0];
  if (child.type !== "paragraph") return null;
  return (child as Paragraph).children;
}
