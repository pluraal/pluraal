import type { HTML as HtmlNode } from "mdast";

/** Renders an mdast html node (raw embedded HTML). */
export function Html({ node }: { node: HtmlNode }) {
  return <div dangerouslySetInnerHTML={{ __html: node.value }} />;
}
