# SpecPM

A package manager for markdown specification files.

## Overview

SpecPM manages markdown files the same way NPM manages TypeScript or JavaScript files. Specification packages are downloaded locally, and a resolution algorithm ensures packages can refer to each other. Markdown files reference each other using URL links and relative URL links, similarly to how imports work in JavaScript/NPM.

Beyond package management, SpecPM provides tree shaking to minimize document size, and LLM context generation to produce custom-tailored files optimized for use as LLM context. The project is a general-purpose solution for managing markdown documents, not limited to specifications.

## Package Management

### NPM as the Foundation

SpecPM builds a thin layer on top of NPM. All specification packages are standard NPM packages that contain markdown files. NPM handles downloading and dependency resolution; SpecPM adds markdown-specific features on top.

### Link Resolution

As part of downloading packages, SpecPM updates links within the markdown files to point to the correct local locations, ensuring no broken links after installation.

## Document Structure Rules

Markdown documents must follow specific structural rules for the tooling to work correctly:

- Documents must be hierarchical, organized into sections using headings.
- Sections must follow content organization rules that enable reliable tree shaking and section extraction.
- Cross-references between sections must use explicit anchor links. If a section depends on information from another section, it must reference that section directly. This is both a requirement for the tooling and good authoring practice, since cross-references help readers navigate the document.

### Section Retention Rule

During tree shaking, a section is retained if:

- It has a parent–child relationship with a required section.
- It is explicitly referenced via an anchor link from a retained section.

In other words, unless a parent–child relationship exists, the only way to keep a section in the output is to reference it directly. This encourages explicit cross-referencing, which benefits both the tooling and human readers.

## LLM Context Generation

SpecPM generates a custom-tailored file that can be used as context for an LLM. The context generator pulls in dependent markdown files, even from other packages, in an efficient way by applying tree-shaking principles.

### How It Works

1. **Follow links** — The tool follows links to other documents but does not include the entire document. It includes only the sections relevant to the reference. If a reference points to an anchor within a document, only that section and its parent sections are included.
2. **Topological ordering** — Included sections are placed before they are used. A simple topological sort determines the order.
3. **Internal anchor replacement** — References to external documents are replaced with internal anchors once the referenced sections are inlined.
4. **Compaction** — After assembly, compaction methods reduce the token count, similar to how JavaScript/TypeScript code is minified.

## LLM-Assisted Restructuring

SpecPM provides instructions, custom agent files, or custom commands that use an LLM to restructure existing markdown files so they conform to the required document structure rules.

## Linting

SpecPM includes linting tools for markdown validation and link verification. These rely on existing tooling from the unified/remark ecosystem.

## CLI

All functionality is exposed through a CLI. Even NPM commands are wrapped behind SpecPM CLI commands, providing a unified interface for:

- Package management (install, update, resolve)
- Tree shaking and compaction
- LLM context generation
- Linting and link verification

## Implementation Plan

1. **Package management layer** — Build the thin NPM wrapper and link resolution logic.
2. **Document structure specification** — Define the precise rules markdown files must follow for the tooling to work.
3. **LLM restructuring tooling** — Create instructions, agent files, or custom commands that use an LLM to restructure existing markdown files to follow the specification.
4. **Tree shaking and compaction** — Implement section extraction, topological ordering, anchor replacement, and compaction.
5. **Linting integration** — Integrate unified/remark for markdown linting and link verification.
6. **CLI** — Expose all features through a unified command-line interface.
