# Language Specification

This specification organizes the language into modular, human-readable markdown files. Each module describes a distinct aspect of the language, focusing on clarity and traceability.

## Modules

### Types

Concrete data types with named member values.

- [Boolean](language/boolean.md) — a two-valued type representing truth: `true` and `false`.
- [Ordering Relation](language/ordering-relation.md) — a three-valued type representing the outcome of a comparison: `Less`, `Equal`, or `Greater`.
- [Integer](language/integer.md) — whole numbers with optional fixed precision and signedness.
- [Floating-Point](language/floating-point.md) — real numbers in binary format with fixed size.
- [Decimal](language/decimal.md) — real numbers in base-10 format with explicit precision and scale.
- [Collection](language/collection.md) — a parameterized type for holding elements with configurable multiplicity, iteration order, and cardinality constraints.

### Type Classes

Shared interfaces that define operations over types. A type _instances_ a type class by implementing its [Required](#required) operations.

- [Equality](language/equality.md) — equality and inequality comparison.
- [Ordering](language/ordering.md) — relative ordering via a three-way [compare](language/ordering.md#compare) operation.
- [Number](language/number.md) — arithmetic operations for numeric types.
- [Fractional](language/fractional.md) — division and related operations for non-integer types.

## Operations

Each operation in a type class module has its own subsection containing:

- A [Required](#required) or [Derived](#derived) marker.
- A description of the operation's semantics.
- A test cases subsection with a table of inputs and expected outputs providing full-coverage test cases.

Heading depth is relative, not absolute. A test cases subsection must appear
under the heading of its operation, but additional grouping sections may
appear between any structural elements. The overall heading hierarchy of a
module is flexible provided that relative containment relationships are
preserved.

Built-in operations have no implementation in the language itself unless they
are [Derived](#derived). Their natural language description and test cases
together serve as the authoritative semantic reference. Derived operations
must reference the required operation(s) they are defined in terms of.

## Alternative Formats

When markdown alone is insufficient for precision or conciseness, alternative
intermediate formats may be used within a module. These may appear as code
blocks inside the markdown file or as separate artifact files referenced from
it. In either case, every alternative-format fragment must carry a provenance
reference --- a link or annotation that identifies the specification section
or operation it belongs to.

## Operation Markers

Each operation in a type class is marked as one of the following:

### Required

The operation must be implemented by any type that instances the type class. It cannot be derived from other operations in the same type class.

### Derived

The operation has a default definition expressed in terms of one or more [Required](#required) operations. A type instancing the type class inherits this definition and does not need to implement it separately, though it may override it.

## User Modules

User modules are markdown files that describe business logic using the language's building blocks. Business logic is expressed as nested lists:

- The parent item is a reference to an operation (linked to its definition in a type class module).
- Each child item is an argument passed to that operation, which may itself be a nested operation call.

This mirrors function application in a readable, non-syntactic form.

### Example

- [Add](language/number.md#addition)
  - [Multiply](language/number.md#multiplication)
    - `unit_price`
    - `quantity`
  - `tax`

This reads as: add the result of multiplying `unit_price` by `quantity` to `tax`.

Leaf values (e.g., `unit_price`) refer to named inputs or constants defined elsewhere in the user module. A [Boolean](language/boolean.md) value can be used as a condition in the [If-Then-Else](language/boolean.md#if-then-else) control-flow construct.
