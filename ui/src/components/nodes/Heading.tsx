import type { Heading as HeadingNode } from "mdast";
import { renderChildren } from "../MarkdownRenderer";

type HeadingTag = "h1" | "h2" | "h3" | "h4" | "h5" | "h6";

/** Renders an mdast heading node (h1–h6). */
export function Heading({ node }: { node: HeadingNode }) {
  const Tag = `h${node.depth}` as HeadingTag;
  const id = slugify(node);
  return <Tag id={id}>{renderChildren(node)}</Tag>;
}

/** Derive a URL-friendly slug from heading text content. */
function slugify(node: HeadingNode): string {
  return extractText(node)
    .toLowerCase()
    .replace(/[^\w\s-]/g, "")
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-")
    .trim();
}

function extractText(node: { children?: unknown[]; value?: string }): string {
  if (typeof node.value === "string") return node.value;
  if (Array.isArray(node.children)) {
    return (node.children as { value?: string; children?: unknown[] }[])
      .map(extractText)
      .join("");
  }
  return "";
}
