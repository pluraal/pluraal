import type { Strong as StrongNode } from "mdast";
import { renderChildren } from "../MarkdownRenderer";

/** Renders an mdast strong node (**bold**). */
export function Strong({ node }: { node: StrongNode }) {
  return <strong>{renderChildren(node)}</strong>;
}
