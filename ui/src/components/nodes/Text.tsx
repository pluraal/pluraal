import type { Text as TextNode } from "mdast";

/** Renders an mdast text node (plain text content). */
export function Text({ node }: { node: TextNode }) {
  return <>{node.value}</>;
}
