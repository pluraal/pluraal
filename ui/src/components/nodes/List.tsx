import type { List as ListNode } from "mdast";
import { renderChildren } from "../MarkdownRenderer";
import { matchIfThenElse, IfThenElse } from "../patterns";

/**
 * Renders an mdast list node (ordered or unordered).
 *
 * Before falling through to default list rendering, checks whether the
 * list matches a known Pluraal pattern (e.g. If-Then-Else) and renders
 * a specialized visual component instead.
 */
export function List({ node }: { node: ListNode }) {
  // --- Pattern detection: If-Then-Else decision tree ---
  const ifThenElse = matchIfThenElse(node);
  if (ifThenElse) {
    return <IfThenElse pattern={ifThenElse} />;
  }

  // --- Default list rendering ---
  const Tag = node.ordered ? "ol" : "ul";
  return (
    <Tag start={node.ordered && node.start != null ? node.start : undefined}>
      {renderChildren(node)}
    </Tag>
  );
}
