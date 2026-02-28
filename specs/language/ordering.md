# Ordering Type Class

## Overview

The Ordering type class defines operations for comparing values to determine their relative order. It extends [Equality](equality.md): any type with an ordering also supports equality comparison.

## Operations

Relational operations return a [Boolean](boolean.md) value.

### Compare

_[Required](../language.md#required)._ Returns an [Ordering Relation](ordering-relation.md) representing the relationship between the first and second value. All other ordering operations are derived from this.

#### Test cases

| Input A | Input B | Output                                  |
| ------- | ------- | --------------------------------------- |
| 1       | 2       | [Less](ordering-relation.md#less)       |
| 2       | 2       | [Equal](ordering-relation.md#equal)     |
| 3       | 2       | [Greater](ordering-relation.md#greater) |

### Less Than

_[Derived](../language.md#derived)._ Returns true when `compare(a, b)` is [Less](ordering-relation.md#less).

#### Test cases

| Input A | Input B | Output |
| ------- | ------- | ------ |
| 1       | 2       | true   |
| 2       | 2       | false  |
| 3       | 2       | false  |

### Greater Than

_[Derived](../language.md#derived)._ Returns true when `compare(a, b)` is [Greater](ordering-relation.md#greater).

#### Test cases

| Input A | Input B | Output |
| ------- | ------- | ------ |
| 1       | 2       | false  |
| 2       | 2       | false  |
| 3       | 2       | true   |

### Less Than or Equal

_[Derived](../language.md#derived)._ Returns true when `compare(a, b)` is not [Greater](ordering-relation.md#greater).

#### Test cases

| Input A | Input B | Output |
| ------- | ------- | ------ |
| 1       | 2       | true   |
| 2       | 2       | true   |
| 3       | 2       | false  |

### Greater Than or Equal

_[Derived](../language.md#derived)._ Returns true when `compare(a, b)` is not [Less](ordering-relation.md#less).

#### Test cases

| Input A | Input B | Output |
| ------- | ------- | ------ |
| 1       | 2       | false  |
| 2       | 2       | true   |
| 3       | 2       | true   |
