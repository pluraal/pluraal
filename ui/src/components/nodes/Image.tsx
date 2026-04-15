import type { Image as ImageNode } from "mdast";

/** Renders an mdast image node. */
export function Image({ node }: { node: ImageNode }) {
  return <img src={node.url} alt={node.alt ?? ""} title={node.title ?? undefined} />;
}
