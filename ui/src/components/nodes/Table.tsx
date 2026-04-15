import type { Table as TableNode } from "mdast";
import { renderNode } from "../MarkdownRenderer";

/**
 * Renders an mdast table node (GFM tables).
 * The first row is treated as the header row.
 */
export function Table({ node }: { node: TableNode }) {
  const [headerRow, ...bodyRows] = node.children;
  const align = node.align ?? [];

  return (
    <table>
      {headerRow && (
        <thead>
          <tr>
            {headerRow.children.map((cell, i) => (
              <th key={i} style={align[i] ? { textAlign: align[i]! } : undefined}>
                {cell.children.map((child, j) => renderNode(child, `${i}-${j}`))}
              </th>
            ))}
          </tr>
        </thead>
      )}
      {bodyRows.length > 0 && (
        <tbody>
          {bodyRows.map((row, ri) => (
            <tr key={ri}>
              {row.children.map((cell, ci) => (
                <td key={ci} style={align[ci] ? { textAlign: align[ci]! } : undefined}>
                  {cell.children.map((child, j) =>
                    renderNode(child, `${ri}-${ci}-${j}`)
                  )}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      )}
    </table>
  );
}
