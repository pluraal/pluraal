import type { Delete as DeleteNode } from "mdast";
import { renderChildren } from "../MarkdownRenderer";

/** Renders a GFM strikethrough node (~~text~~). */
export function Delete({ node }: { node: DeleteNode }) {
  return <del>{renderChildren(node)}</del>;
}
