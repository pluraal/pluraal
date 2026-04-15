import type { Link as LinkNode } from "mdast";
import { renderChildren } from "../MarkdownRenderer";

/** Renders an mdast link node. */
export function Link({ node }: { node: LinkNode }) {
  return (
    <a href={node.url} title={node.title ?? undefined}>
      {renderChildren(node)}
    </a>
  );
}
