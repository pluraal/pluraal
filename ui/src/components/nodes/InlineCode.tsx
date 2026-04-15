import type { InlineCode as InlineCodeNode } from "mdast";

/** Renders an mdast inline code node (`code`). */
export function InlineCode({ node }: { node: InlineCodeNode }) {
  return <code>{node.value}</code>;
}
