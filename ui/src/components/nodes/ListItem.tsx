import type { ListItem as ListItemNode } from "mdast";
import { renderChildren } from "../MarkdownRenderer";

/** Renders an mdast list item node. Handles GFM task-list checkboxes. */
export function ListItem({ node }: { node: ListItemNode }) {
  if (typeof node.checked === "boolean") {
    return (
      <li className="task-list-item">
        <input type="checkbox" checked={node.checked} readOnly />
        {renderChildren(node)}
      </li>
    );
  }
  return <li>{renderChildren(node)}</li>;
}
