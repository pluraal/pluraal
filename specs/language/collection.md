# Collection

## Overview

A Collection is a parameterized type that holds zero or more elements of a given element type `T`. Collections are characterized by four type attributes:

- **multiplicity** — governs whether duplicate elements are permitted.
- **iteration order** — governs the sequence in which elements are visited during iteration.
- **minimum cardinality** — the minimum number of elements the collection must contain.
- **maximum cardinality** (optional) — the maximum number of elements the collection may contain.

## Attributes

### Multiplicity

Governs whether duplicate elements are permitted:

- **unique** — no two elements compare [Equal](equality.md#equal) under the element type's [Equality](equality.md) instance. Adding a duplicate element leaves the collection unchanged.
- **multi** — duplicate elements are permitted; the same value may appear more than once.

### Iteration Order

Governs the sequence in which elements are visited during iteration:

- **none** — no iteration order is guaranteed.
- **insertion** — elements are visited in the order they were added.
- **key** — elements are visited in ascending order defined by a [Compare](ordering.md#compare) expression over a key derived from each element, equivalent to SQL `ORDER BY`. When two elements produce equal keys, a tie-breaking rule applies:
  - **stable** — elements with equal keys retain their relative insertion order.
  - **unstable** — the relative order of elements with equal keys is unspecified.

### Minimum Cardinality

The minimum number of elements the collection must contain. When the minimum cardinality is `1` or more, the collection is _non-empty_. Defaults to `0`.

### Maximum Cardinality

The maximum number of elements the collection may contain. When unspecified, the collection is unbounded.

## Operations

### Size

_[Required](../language.md#required)._ Returns the number of elements in the collection.

#### Test cases

| Collection | Output |
| ---------- | ------ |
| []         | 0      |
| [1]        | 1      |
| [1, 2, 3]  | 3      |
| [1, 1, 2]  | 3      |

### Is Empty

_[Derived](../language.md#derived)._ Returns [Boolean](boolean.md) `true` if the collection contains no elements. Defined as [Size](#size) equal to zero.

#### Test cases

| Collection | Output |
| ---------- | ------ |
| []         | true   |
| [1]        | false  |
| [1, 2, 3]  | false  |

### Contains

_[Required](../language.md#required)._ Precondition: element type implements [Equality](equality.md). Returns [Boolean](boolean.md) `true` if any element in the collection compares [Equal](equality.md#equal) to the given value.

#### Test cases

| Collection | Value | Output |
| ---------- | ----- | ------ |
| [1, 2, 3]  | 2     | true   |
| [1, 2, 3]  | 4     | false  |
| []         | 1     | false  |
| [1, 1, 2]  | 1     | true   |

### Map

_[Required](../language.md#required)._ Returns a new collection of the same multiplicity and iteration order containing the result of applying a given function to each element. The output cardinality equals the input cardinality.

#### Test cases

| Collection | Function          | Output    |
| ---------- | ----------------- | --------- |
| [1, 2, 3]  | add 1 to element  | [2, 3, 4] |
| []         | add 1 to element  | []        |
| [2, 2, 3]  | add 1 to element  | [3, 3, 4] |

### Filter

_[Required](../language.md#required)._ Returns a new collection containing only the elements for which a given predicate returns [Boolean](boolean.md) `true`, preserving multiplicity and iteration order.

#### Test cases

| Collection | Predicate              | Output |
| ---------- | ---------------------- | ------ |
| [1, 2, 3]  | element greater than 1 | [2, 3] |
| [1, 2, 3]  | element greater than 5 | []     |
| []         | any element            | []     |
| [1, 1, 2]  | element less than 2    | [1, 1] |

### Distinct

_[Required](../language.md#required)._ Precondition: element type implements [Equality](equality.md). Returns a new collection with duplicates removed so that no two elements compare [Equal](equality.md#equal). The resulting collection has multiplicity **unique**.

When iteration order is **insertion** or **key**, the first occurrence of each distinct value is retained and relative order is preserved (stable). When iteration order is **none**, the relative order of retained elements is unspecified.

#### Test cases

| Collection   | Output    |
| ------------ | --------- |
| [1, 2, 1, 3] | [1, 2, 3] |
| [1, 1, 1]    | [1]       |
| []           | []        |
| [3, 1, 2, 1] | [3, 1, 2] |

### Union

_[Required](../language.md#required)._ Precondition: element type implements [Equality](equality.md). Returns a collection containing all elements from either collection.

- For **unique** collections: each distinct element appears exactly once (set union).
- For **multi** collections: each element appears as many times as the sum of its occurrences across both collections (bag union).

#### Test cases

| Collection A | Collection B | Output (unique) |
| ------------ | ------------ | --------------- |
| [1, 2]       | [2, 3]       | [1, 2, 3]       |
| [1, 2]       | []           | [1, 2]          |
| []           | [3]          | [3]             |
| []           | []           | []              |

### Intersect

_[Required](../language.md#required)._ Precondition: element type implements [Equality](equality.md). Returns a collection containing only elements that appear in both collections.

- For **unique** collections: each distinct common element appears exactly once (set intersection).
- For **multi** collections: each element appears as many times as the minimum of its occurrences in each collection (bag intersection).

#### Test cases

| Collection A | Collection B | Output (unique) |
| ------------ | ------------ | --------------- |
| [1, 2, 3]    | [2, 3, 4]    | [2, 3]          |
| [1, 2]       | [3, 4]       | []              |
| []           | [1]          | []              |
| [1, 2]       | []           | []              |

### Difference

_[Required](../language.md#required)._ Precondition: element type implements [Equality](equality.md). Returns a collection containing elements from the first collection that do not appear in the second.

- For **unique** collections: each element of the first that is absent from the second appears exactly once (set difference).
- For **multi** collections: the occurrence count of each element is reduced by its occurrence count in the second collection, with a floor of zero (bag difference).

#### Test cases

| Collection A | Collection B | Output (unique) |
| ------------ | ------------ | --------------- |
| [1, 2, 3]    | [2, 3]       | [1]             |
| [1, 2]       | [3, 4]       | [1, 2]          |
| []           | [1]          | []              |
| [1, 2, 3]    | []           | [1, 2, 3]       |

### Sort By

_[Required](../language.md#required)._ Precondition: a key function and a [Compare](ordering.md#compare) expression over the key type are provided. Returns a new collection with elements ordered by the key in ascending order. The resulting collection has iteration order **key**. Tie-breaking is stable: elements with equal keys retain their relative input order.

#### Test cases

| Collection      | Key function            | Output         |
| --------------- | ----------------------- | -------------- |
| [3, 1, 2]       | element itself          | [1, 2, 3]      |
| [2, 2, 1]       | element itself          | [1, 2, 2]      |
| []              | element itself          | []             |
| [(b,1), (a,2)]  | first component of pair | [(a,2), (b,1)] |

### Then By

_[Derived](../language.md#derived)._ Precondition: a preceding [Sort By](#sort-by) or Then By has established a primary key ordering; a secondary key function and [Compare](ordering.md#compare) expression over the secondary key type are provided. Returns a new collection where elements with equal primary keys are further ordered by the secondary key. Tie-breaking on the secondary key is stable. Defined in terms of [Sort By](#sort-by) applied to a composite key that lexicographically combines the primary and secondary keys.

#### Test cases

| Collection              | Primary key             | Secondary key           | Output                  |
| ----------------------- | ----------------------- | ----------------------- | ----------------------- |
| [(a,2), (a,1), (b,1)]   | first component of pair | second component of pair | [(a,1), (a,2), (b,1)]  |
| [(b,2), (a,1), (a,2)]   | first component of pair | second component of pair | [(a,1), (a,2), (b,2)]  |

### Min

_[Required](../language.md#required)._ Precondition: element type implements [Ordering](ordering.md); minimum cardinality ≥ 1. Returns the smallest element according to [Compare](ordering.md#compare). If multiple elements are [Equal](ordering-relation.md#equal), any one of them may be returned.

#### Test cases

| Collection | Output |
| ---------- | ------ |
| [3, 1, 2]  | 1      |
| [5]        | 5      |
| [1, 1, 2]  | 1      |

### Max

_[Required](../language.md#required)._ Precondition: element type implements [Ordering](ordering.md); minimum cardinality ≥ 1. Returns the largest element according to [Compare](ordering.md#compare). If multiple elements are [Equal](ordering-relation.md#equal), any one of them may be returned.

#### Test cases

| Collection | Output |
| ---------- | ------ |
| [3, 1, 2]  | 3      |
| [5]        | 5      |
| [1, 2, 2]  | 2      |

### Min Or None

_[Derived](../language.md#derived)._ Precondition: element type implements [Ordering](ordering.md). Returns the smallest element if the collection is non-empty, or an absent value otherwise. Defined in terms of [Is Empty](#is-empty) and [Min](#min).

#### Test cases

| Collection | Output |
| ---------- | ------ |
| [3, 1, 2]  | 1      |
| [5]        | 5      |
| []         | none   |

### Max Or None

_[Derived](../language.md#derived)._ Precondition: element type implements [Ordering](ordering.md). Returns the largest element if the collection is non-empty, or an absent value otherwise. Defined in terms of [Is Empty](#is-empty) and [Max](#max).

#### Test cases

| Collection | Output |
| ---------- | ------ |
| [3, 1, 2]  | 3      |
| [5]        | 5      |
| []         | none   |

### Reduce

_[Required](../language.md#required)._ Precondition: minimum cardinality ≥ 1. Combines all elements using a binary associative function without an initial accumulator, returning a single value of the same type.

#### Test cases

| Collection | Function          | Output |
| ---------- | ----------------- | ------ |
| [1, 2, 3]  | sum of two values | 6      |
| [5]        | sum of two values | 5      |
| [2, 3, 4]  | max of two values | 4      |

### Reduce Or None

_[Derived](../language.md#derived)._ Like [Reduce](#reduce) but returns an absent value when the collection is empty. Defined in terms of [Is Empty](#is-empty) and [Reduce](#reduce).

#### Test cases

| Collection | Function          | Output |
| ---------- | ----------------- | ------ |
| [1, 2, 3]  | sum of two values | 6      |
| [5]        | sum of two values | 5      |
| []         | sum of two values | none   |

### Sum

_[Derived](../language.md#derived)._ Precondition: element type implements [Number](number.md). Returns the total of all elements. Defined as [Reduce](#reduce) with [Addition](number.md#addition) when the collection is non-empty, and zero otherwise.

#### Test cases

| Collection | Output |
| ---------- | ------ |
| [1, 2, 3]  | 6      |
| [5]        | 5      |
| []         | 0      |
| [2, 2, 2]  | 6      |

### Average

_[Derived](../language.md#derived)._ Precondition: element type implements [Number](number.md); minimum cardinality ≥ 1. Returns the arithmetic mean of all elements. Defined as [Sum](#sum) divided by [Size](#size).

#### Test cases

| Collection | Output |
| ---------- | ------ |
| [1, 2, 3]  | 2      |
| [2, 4]     | 3      |
| [5]        | 5      |

## Type Class Instances

Collection does not itself implement a type class. The applicability of individual operations depends on the element type's type class instances and the collection's attribute values, as stated in each operation's preconditions.
