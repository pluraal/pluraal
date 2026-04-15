import type { Paragraph as ParagraphNode } from "mdast";
import { renderChildren } from "../MarkdownRenderer";

/** Renders an mdast paragraph node. */
export function Paragraph({ node }: { node: ParagraphNode }) {
  return <p>{renderChildren(node)}</p>;
}
