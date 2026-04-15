import type { LinkReference as LinkRefNode } from "mdast";
import { renderChildren } from "../MarkdownRenderer";

/**
 * Renders an mdast linkReference node.
 * In a full implementation, this would resolve against collected definitions.
 * For now, it renders the children as a placeholder span with a data attribute.
 */
export function LinkReference({ node }: { node: LinkRefNode }) {
  return (
    <span className="link-reference" data-identifier={node.identifier}>
      {renderChildren(node)}
    </span>
  );
}
