# Boolean Module

## Overview

The Boolean type represents a fundamental data type with two distinct member values: **true** and **false**. It is used to express binary logic, decision making, and control flow within specifications and executable models.

## Member Values

- **true**: Represents affirmation, presence, or logical truth.
- **false**: Represents negation, absence, or logical falsehood.

## Operations

Each operation is described with its truth table, which serves as both a specification and a full-coverage test suite.

### NOT (Negation)

Inverts the value of a Boolean.

| Input | Output |
| ----- | ------ |
| true  | false  |
| false | true   |

### AND (Conjunction)

Returns true if and only if both inputs are true.

| Input A | Input B | Output |
| ------- | ------- | ------ |
| true    | true    | true   |
| true    | false   | false  |
| false   | true    | false  |
| false   | false   | false  |

### OR (Disjunction)

Returns true if at least one input is true.

| Input A | Input B | Output |
| ------- | ------- | ------ |
| true    | true    | true   |
| true    | false   | true   |
| false   | true    | true   |
| false   | false   | false  |

### XOR (Exclusive OR)

Returns true if exactly one input is true.

| Input A | Input B | Output |
| ------- | ------- | ------ |
| true    | true    | false  |
| true    | false   | true   |
| false   | true    | true   |
| false   | false   | false  |

### IMPLIES (Material Implication)

Returns false only when the antecedent is true and the consequent is false.

| Input A | Input B | Output |
| ------- | ------- | ------ |
| true    | true    | true   |
| true    | false   | false  |
| false   | true    | true   |
| false   | false   | true   |

## Type Class Instances

Boolean implements [Equality](equality.md): two Boolean values are equal when they are the same member.
