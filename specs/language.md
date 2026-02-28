# Language Specification Layout

This specification organizes the language into modular, human-readable markdown files. Each module describes a distinct aspect of the language, focusing on clarity and traceability.

## Structure

- **language.md**: High-level overview and layout of the language specification.
- **language/boolean.md**: Defines the Boolean type, its member values (true, false), and core Boolean operations with truth tables.
- **language/ordering-relation.md**: Defines the Ordering Relation type, representing the outcome of a comparison: Less, Equal, or Greater.
- **language/equality.md**: Describes the Equality type class, covering equality and inequality operations.
- **language/ordering.md**: Specifies the Ordering type class, covering relational operations for types with order using Ordering Relation as the compare result.
- **language/number.md**: Details the Number type class, including arithmetic operations for numeric types.

## Principles

- Each module is self-contained and focused on a single concept or type class.
- Operations are described in terms of their semantics and testable truth tables, not language-specific syntax.
- The layout supports extension with additional types, type classes, or domain-specific modules as needed.

## Operation Markers

Each operation in a type class is marked as one of the following:

### Required

The operation must be implemented by any type that instances the type class. It cannot be derived from other operations in the same type class.

### Derived

The operation has a default definition expressed in terms of one or more [Required](#required) operations. A type instancing the type class inherits this definition and does not need to implement it separately, though it may override it.

This structure enables spec-driven development, clear documentation, and systematic verification of language features.
