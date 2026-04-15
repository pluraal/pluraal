import type { IfThenElsePattern } from "./detectIfThenElse";
import { renderNode } from "../MarkdownRenderer";
import type { PhrasingContent } from "mdast";

/**
 * Renders an If-Then-Else operation as a visual decision tree.
 *
 * Layout:
 *   ┌─────────────────────┐
 *   │   If-Then-Else      │  ← operation badge
 *   └─────────────────────┘
 *            │
 *     ┌──────┴──────┐
 *     │  condition  │       ← diamond/condition node
 *     └──────┬──────┘
 *        ┌───┴───┐
 *    yes │       │ no
 *   ┌────┴──┐ ┌──┴────┐
 *   │ then  │ │ else  │     ← leaf value nodes
 *   └───────┘ └───────┘
 */
export function IfThenElse({ pattern }: { pattern: IfThenElsePattern }) {
  return (
    <div className="decision-tree" role="img" aria-label="If-Then-Else decision tree">
      {/* Operation header */}
      <div className="dt-header">
        <a className="dt-operation-link" href={pattern.operationUrl}>
          {pattern.operationLabel}
        </a>
      </div>

      {/* Connector from header to condition */}
      <div className="dt-connector" aria-hidden="true" />

      {/* Condition diamond */}
      <div className="dt-condition">
        <div className="dt-diamond" aria-label="Condition">
          <span className="dt-diamond-content">
            <InlineContent nodes={pattern.condition} />
          </span>
        </div>
      </div>

      {/* Branch connectors */}
      <div className="dt-branches" aria-hidden="true">
        <div className="dt-branch dt-branch-yes">
          <span className="dt-branch-label">true</span>
        </div>
        <div className="dt-branch dt-branch-no">
          <span className="dt-branch-label">false</span>
        </div>
      </div>

      {/* Leaf values */}
      <div className="dt-leaves">
        <div className="dt-leaf dt-leaf-yes" aria-label="Value when true">
          <InlineContent nodes={pattern.thenBranch} />
        </div>
        <div className="dt-leaf dt-leaf-no" aria-label="Value when false">
          <InlineContent nodes={pattern.elseBranch} />
        </div>
      </div>
    </div>
  );
}

/** Renders an array of phrasing content nodes inline. */
function InlineContent({ nodes }: { nodes: PhrasingContent[] }) {
  return (
    <>
      {nodes.map((node, i) => renderNode(node, String(i)))}
    </>
  );
}
