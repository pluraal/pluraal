import type { Emphasis as EmphasisNode } from "mdast";
import { renderChildren } from "../MarkdownRenderer";

/** Renders an mdast emphasis node (*italic*). */
export function Emphasis({ node }: { node: EmphasisNode }) {
  return <em>{renderChildren(node)}</em>;
}
