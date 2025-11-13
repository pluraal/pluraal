# Copilot Instructions for Pluraal

When generating code or documentation for the Pluraal project, please follow these guidelines:

- In agent mode, ask questions to clarify requirements or gather additional context before proceeding with code generation.
- When a new piece of information is received from the developer, ensure it is incorporated into the relevant sections of the documentation, codebase or the `copilot-instructions.md`.

## Project Overview

This is a dual-language project implementing a declarative language for rules and logic:

- **TypeScript**: MCP (Model Context Protocol) server implementation
- **Elm**: Core language library with type-safe evaluation

The language design separates `Scope` as a top-level construct (not an expression type), allowing for clear separation between expressions and scope evaluation.

## Architecture Patterns

### Module Organization

Follow the `OriginalModule.Codec` pattern for JSON serialization:

- Keep core logic in the main module (e.g., `Pluraal.Language`)
- Move JSON encoding/decoding to a separate `.Codec` module (e.g., `Pluraal.Language.Codec`)
- Always update `elm.json` exposed-modules when adding new public modules

### Elm Naming Conventions

- Use descriptive constructor names to avoid conflicts with type aliases
- Examples: `IfThenElseBranch` instead of `IfThenElse` for constructors
- Use `Decode.lazy` for recursive type decoders to handle cyclic dependencies

### Elm Dependency Management

- Use `elm install <package>` to add new Elm dependencies instead of manually editing `elm.json`
- This ensures proper version resolution and constraint handling
- Only edit `elm.json` manually for exposed-modules when creating new public modules
- Let Elm's package manager handle dependency versions and compatibility

### Testing Requirements

- All TypeScript changes must maintain existing tests (Vitest)
- All Elm changes must maintain existing tests (elm-test)
- Run tests after any refactoring to ensure functionality is preserved

## Development Workflow

1. Make changes to core logic
2. Update or create corresponding `.Codec` modules for JSON serialization
3. Update `elm.json` exposed-modules if adding new public modules
4. Run tests to verify changes
5. Update documentation as needed

## Common Patterns

- Use Zod for TypeScript validation
- Use strict typing throughout
- Follow separation of concerns (logic vs serialization)
- Maintain comprehensive test coverage

## UI Design Principles

- **Real-time Evaluation**: The ScopeViewer UI automatically evaluates scopes when inputs change, providing immediate feedback without requiring manual action
- **Responsive Interface**: UI should provide clear visual feedback for loading states, errors, and successful evaluations
- **Type-safe Inputs**: Input validation should respect the Pluraal type system (String, Number, Boolean)
