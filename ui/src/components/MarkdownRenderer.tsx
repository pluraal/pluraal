import type { ReactNode } from "react";
import type { Root, RootContent, PhrasingContent } from "mdast";
import {
  Heading,
  Paragraph,
  Text,
  Emphasis,
  Strong,
  Link,
  List,
  ListItem,
  Table,
  Code,
  InlineCode,
  Blockquote,
  ThematicBreak,
  Image,
  Break,
  Html,
  Definition,
  Delete,
  LinkReference,
} from "./nodes";

// Union of all content node types we may encounter
type AnyNode = RootContent | PhrasingContent;

/**
 * Render a single mdast node to its corresponding React element.
 *
 * Each node type dispatches to its own dedicated component module so that
 * individual markdown features can be independently extended or replaced
 * with specialized Pluraal visual components.
 */
export function renderNode(node: AnyNode, key?: string): ReactNode {
  switch (node.type) {
    case "heading":
      return <Heading key={key} node={node} />;
    case "paragraph":
      return <Paragraph key={key} node={node} />;
    case "text":
      return <Text key={key} node={node} />;
    case "emphasis":
      return <Emphasis key={key} node={node} />;
    case "strong":
      return <Strong key={key} node={node} />;
    case "link":
      return <Link key={key} node={node} />;
    case "list":
      return <List key={key} node={node} />;
    case "listItem":
      return <ListItem key={key} node={node} />;
    case "table":
      return <Table key={key} node={node} />;
    case "code":
      return <Code key={key} node={node} />;
    case "inlineCode":
      return <InlineCode key={key} node={node} />;
    case "blockquote":
      return <Blockquote key={key} node={node} />;
    case "thematicBreak":
      return <ThematicBreak key={key} />;
    case "image":
      return <Image key={key} node={node} />;
    case "break":
      return <Break key={key} />;
    case "html":
      return <Html key={key} node={node} />;
    case "definition":
      return <Definition key={key} node={node} />;
    case "delete":
      return <Delete key={key} node={node} />;
    case "linkReference":
      return <LinkReference key={key} node={node} />;
    default:
      // Fallback: render as a debug placeholder for unhandled node types
      console.warn(`Unhandled mdast node type: ${(node as AnyNode).type}`);
      return (
        <span key={key} className="unhandled-node" data-type={(node as AnyNode).type}>
          {"children" in node
            ? renderChildren(node as { children: AnyNode[] })
            : "value" in node
              ? String((node as { value: unknown }).value)
              : null}
        </span>
      );
  }
}

/**
 * Render all children of a parent node.
 * Exported for use by individual node components.
 */
export function renderChildren(
  parent: { children: AnyNode[] } | { children: RootContent[] }
): ReactNode[] {
  return (parent.children as AnyNode[]).map((child, i) =>
    renderNode(child, String(i))
  );
}

/**
 * Top-level component that renders a complete mdast Root tree.
 */
export function MarkdownRenderer({ tree }: { tree: Root }) {
  return <div className="markdown-body">{renderChildren(tree)}</div>;
}
