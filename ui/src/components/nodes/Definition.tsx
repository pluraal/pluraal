import type { Definition as DefinitionNode } from "mdast";

/**
 * Renders an mdast definition node (link reference definitions like [id]: url).
 * These are invisible in rendered output but could be shown for debugging.
 */
export function Definition({ node }: { node: DefinitionNode }) {
  // Link reference definitions are not rendered visually in standard markdown.
  // We keep the component for future use (e.g., showing provenance or debugging).
  return null;
}
