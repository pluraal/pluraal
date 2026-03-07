# Optional

## Overview

An Optional is a parametric type over a value type `T` that represents either a present value or the absence of a value. It models nullable semantics — analogous to `NULL` in SQL, `Option` in Rust, and `Maybe` in Haskell.

Optionals arise naturally in relational operations such as [Left Join](relation.md#left-join) and [Full Join](relation.md#full-join), where unmatched rows produce absent field values.

## Parameters

| Name | Description                              |
| ---- | ---------------------------------------- |
| `T`  | The type of the value when present.      |

## Member Values

- **some** — a present value of type `T`.
- **none** — the absence of a value.

## Operations

### Is Present

_[Required][req]._ Returns [Boolean][bool] `true` when the Optional holds a value, `false` when it is **none**.

#### Test cases

| Optional | Output |
| -------- | ------ |
| some(1)  | true   |
| some(0)  | true   |
| none     | false  |

### Value Or Default

_[Required][req]._ Returns the contained value when the Optional is **some**, or a provided default value of the same type when it is **none**.

#### Test cases

| Optional | Default | Output |
| -------- | ------- | ------ |
| some(5)  | 0       | 5      |
| none     | 0       | 0      |
| some(3)  | 10      | 3      |
| none     | 7       | 7      |

### Map

_[Required][req]._ Applies a function to the contained value when the Optional is **some**, returning a new Optional with the result. Returns **none** unchanged when the Optional is **none**.

#### Test cases

| Optional | Function         | Output  |
| -------- | ---------------- | ------- |
| some(2)  | add 1 to value   | some(3) |
| none     | add 1 to value   | none    |
| some(5)  | multiply by 2    | some(10)|

### Flat Map

_[Required][req]._ Applies a function that itself returns an Optional to the contained value when the Optional is **some**. Returns **none** unchanged when the Optional is **none**. This avoids nested Optionals.

#### Test cases

| Optional | Function                                 | Output  |
| -------- | ---------------------------------------- | ------- |
| some(4)  | if positive then some(value) else none   | some(4) |
| some(-1) | if positive then some(value) else none   | none    |
| none     | if positive then some(value) else none   | none    |

### Filter

_[Required][req]._ Returns the Optional unchanged when it is **some** and the predicate returns [Boolean][bool] `true`. Returns **none** in all other cases.

#### Test cases

| Optional | Predicate            | Output  |
| -------- | -------------------- | ------- |
| some(3)  | value greater than 2 | some(3) |
| some(1)  | value greater than 2 | none    |
| none     | value greater than 2 | none    |

## Type Class Instances

### Equality

Two Optionals are [Equal][eq-equal] when both are **none**, or both are **some** and their contained values are [Equal][eq-equal]. A **some** value is never equal to **none**.

| a       | b       | Equal |
| ------- | ------- | ----- |
| some(1) | some(1) | true  |
| some(1) | some(2) | false |
| none    | none    | true  |
| some(1) | none    | false |
| none    | some(1) | false |

[bool]: boolean.md
[eq-equal]: equality.md#equal
[req]: ../language.md#required
