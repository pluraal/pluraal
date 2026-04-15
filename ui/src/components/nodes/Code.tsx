import type { Code as CodeNode } from "mdast";

/** Renders an mdast code block node (fenced or indented). */
export function Code({ node }: { node: CodeNode }) {
  return (
    <pre>
      <code className={node.lang ? `language-${node.lang}` : undefined}>
        {node.value}
      </code>
    </pre>
  );
}
