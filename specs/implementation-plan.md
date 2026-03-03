# Implementation Plan

This plan translates the [vision](vision.md) into concrete, sequenced
work. Each phase builds on the previous one and delivers a usable
increment.

---

## Phase 1 — Language Core and Specification Parsing

**Goal:** establish the foundational data model and markdown parser so
that specification modules can be loaded, validated structurally, and
executed against embedded test cases.

### Deliverables

1. **Markdown parser** — read a specification module and produce an
   in-memory representation of its headings, prose, operations, and
   test-case tables. Respect the relative-heading-depth convention
   described in [§ 2.4](vision.md#24-structured--human-readable-hybrid).
2. **Type and type-class registry** — load the modules under
   [language/](language.md) into a registry of types, type classes,
   operations, and their relationships.
3. **Expression evaluator** — evaluate derived operations and test-case
   expressions against the registry.
4. **CLI `test`, `eval`, `list` commands** — as specified in
   [CLI](tools/cli.md).

### Current State

The parser ([src/parse.ts](../src/parse.ts)), interpreter
([src/interpreter.ts](../src/interpreter.ts)), test runner
([src/test-runner.ts](../src/test-runner.ts)), and CLI
([src/cli.ts](../src/cli.ts)) already exist. Ongoing work in this phase
focuses on hardening, adding missing operations, and increasing test
coverage across the full [language specification](language.md).

---

## Phase 2 — Static Verification

**Goal:** catch specification errors before execution, covering the
checks described in [§ 4.1](vision.md#41-static-verification).

### Deliverables

1. **Structural validation** — verify that every module follows the
   expected heading hierarchy (overview, operations, test cases) using
   relative depth rules.
2. **Schema consistency** — confirm that every operation declares inputs,
   an output type, and required/derived status.
3. **Dependency completeness** — ensure every cross-module reference
   resolves (types, type classes, operations) and that the dependency
   graph is acyclic.
4. **Orphan detection** — flag operations, types, or test cases that are
   declared but never referenced or reachable.
5. **CLI integration** — surface verification results through a new
   `pluraal check <file|dir>` command that reports errors against
   originating specification fragments.

---

## Phase 3 — Provenance Model

**Goal:** implement the source-map-like provenance described in
[§ 3.3](vision.md#33-source-map-like-provenance) so that every
structured node can be traced back to its markdown origin.

### Deliverables

1. **Provenance metadata on parsed nodes** — attach source location
   (file, heading path, line range) to every type, operation, and
   test-case node in the in-memory graph.
2. **Provenance in error messages** — all verification and runtime errors
   reference the originating specification fragment by file and heading
   path.
3. **Provenance serialization** — expose provenance as a JSON sidecar so
   that downstream tools (projections, debuggers) can consume it without
   re-parsing markdown.

---

## Phase 4 — Type Inference and Document Enrichment

**Goal:** build the type-inference tool described in
[§ 10](vision.md#10-type-inference-and-document-enrichment).

### Deliverables

1. **Type inference engine** — walk the specification graph, propagate
   declared types through derived operations, and infer types for
   unannnotated terms where possible.
2. **Type checker** — validate that inferred types are consistent across
   module boundaries (input/output type agreement, correct type-class
   instance constraints).
3. **Document enrichment writer** — augment the markdown source
   non-destructively by inserting inline footnotes using extended
   Markdown caret notation (`^[inferred type: Boolean]`) at each
   annotated term.
4. **Round-trip fidelity tests** — verify that parsing an enriched
   document produces the same semantic graph as the original, and that
   re-enrichment is idempotent.
5. **CLI integration** — `pluraal enrich <file|dir>` writes enriched
   files in-place (or to a separate output directory).

---

## Phase 5 — Executable Specification Graph

**Goal:** materialize the typed dataflow graph described in
[§ 3.1](vision.md#31-executable-specification-graph) as a first-class
runtime structure.

### Deliverables

1. **Graph builder** — construct a directed acyclic graph of operations
   from the parsed specification, with nodes for transformations and
   edges for data contracts.
2. **Topological executor** — execute the graph in dependency order,
   supporting both full-run and single-node evaluation modes.
3. **Graph serialization** — export the graph as a JSON or DOT artifact
   for visualization and tooling consumption.

---

## Phase 6 — Language Projections

**Goal:** enable automatic derivation of target-language implementations
as described in [§ 9](vision.md#9-language-projections).

### Deliverables

1. **Projection framework** — define the contract a projection must
   satisfy: preserve semantics, pass all spec test cases, maintain
   provenance links.
2. **TypeScript projection** — generate TypeScript source from a
   specification module. Built-in operations map to native operators;
   derived operations emit the corresponding function composition.
3. **Projection validator** — run the specification's test cases against
   the projected implementation and report mismatches.
4. **Provenance comments** — embed source-map-style comments in the
   projected code linking back to the originating specification heading.
5. **CLI integration** — `pluraal project <file> --target ts` generates
   the projection and optionally runs validation.

---

## Phase 7 — Live Data Binding and Specification Debugging

**Goal:** implement the markdown-native debugger described in
[§ 11](vision.md#11-live-data-binding-and-specification-debugging).

### Deliverables

1. **Data-source adapters** — pluggable adapters for binding a
   specification to a database connection (e.g., PostgreSQL, SQLite), a
   CSV/JSON file, or an in-memory dataset.
2. **Execution engine with step control** — extend the topological
   executor to support pause, step-forward, and resume, emitting events
   at each operation boundary.
3. **Markdown overlay renderer** — a rendering layer (VS Code extension
   or browser-based) that displays the specification document and
   overlays live values, highlights the active step, and annotates rule
   conditions as they evaluate.
4. **Inspect interaction** — hover or select any term in the rendered
   document to see its current bound value and the data-source row or
   column it originated from.
5. **Replay** — re-run the same bound dataset after a specification edit,
   resetting execution state while preserving the data binding.

---

## Phase 8 — Immediate Impact Analysis

**Goal:** deliver the tight feedback loop described in
[§ 12](vision.md#12-immediate-impact-analysis).

### Deliverables

1. **Snapshot capture** — before each execution, snapshot all operation
   outputs so they can be compared after an edit.
2. **Output differ** — after re-execution, compute a structured diff
   between the previous and current output snapshots, identifying
   changed values, newly passing/failing cases, and transitively
   affected derived results.
3. **Diff overlay in markdown view** — present the diff inline in the
   rendered markdown: changed values annotated with old → new, affected
   rows highlighted, transitive impacts surfaced even for operations the
   user did not directly edit.
4. **Integration with live debugger** — the impact analysis operates
   within the same markdown overlay as the Phase 7 debugger, requiring
   no additional UI or context switch.

---

## Phase 9 — LLM Integration Layer

**Goal:** formalize the LLM-native workflows described in
[§ 2.3](vision.md#23-llm-native-by-design).

### Deliverables

1. **Structured-semantics extraction** — given a natural-language
   description, produce a candidate specification fragment (operations,
   test cases, type annotations) that can be inserted into a module.
2. **Natural-language regeneration** — given a specification subgraph,
   regenerate human-readable prose that faithfully describes its
   semantics.
3. **Partial subtree regeneration** — regenerate a single operation or
   section without affecting the rest of the document.
4. **Semantic diffing** — compare two versions of a specification at the
   graph level rather than the text level, surfacing meaningful semantic
   changes (new operations, altered types, changed test expectations).
5. **Deterministic regeneration** — ensure that repeated regeneration of
   the same subgraph under the same constraints produces identical
   output.

---

## Phase 10 — Dynamic Verification and Productionization

**Goal:** complete the verification model
([§ 4.2](vision.md#42-dynamic-verification)) and the productionization
path ([§ 6](vision.md#6-productionization-path)).

### Deliverables

1. **Property-based testing** — support property declarations (e.g.,
   algebraic laws) alongside example tables, with automatic generation
   of test inputs.
2. **Data-contract enforcement** — validate that data flowing between
   operations satisfies declared type and cardinality constraints at
   runtime.
3. **Invariant checking** — evaluate user-declared invariants after each
   operation step and surface violations immediately.
4. **Productionization pipeline** — orchestrate the full path from
   exploratory specification through verified executable to language
   projection and deployment artifact (container, serverless bundle,
   etc.).
5. **Documentation generation** — derive standalone documentation
   (HTML, PDF) from the specification, incorporating type enrichment and
   provenance metadata.

---

## Phase Dependencies

```text
Phase 1  ──► Phase 2  ──► Phase 3  ──► Phase 4
                                          │
                                          ▼
                                       Phase 5  ──► Phase 6
                                          │
                                          ▼
                                       Phase 7  ──► Phase 8
                                          │
                                          ▼
                                       Phase 9  ──► Phase 10
```

Phases are sequential where noted. Phases 6 (projections) and 7
(debugger) can proceed in parallel once Phase 5 is complete. Phase 9
(LLM integration) can begin alongside Phase 7 but is listed later
because it depends on a mature semantic graph.
