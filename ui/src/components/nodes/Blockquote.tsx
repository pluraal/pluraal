import type { Blockquote as BlockquoteNode } from "mdast";
import { renderChildren } from "../MarkdownRenderer";

/** Renders an mdast blockquote node. */
export function Blockquote({ node }: { node: BlockquoteNode }) {
  return <blockquote>{renderChildren(node)}</blockquote>;
}
