# Record

## Overview

A Record is a finite, ordered collection of named fields, where each field has a name and a typed value. Records represent structured data rows — analogous to a row in SQL, a `StructType` in Spark, and a `Struct` in Polars.

A Record's shape is defined by its **schema**: the ordered list of (field-name, field-type) pairs. Two Records share a schema when they have the same field names in the same order with the same types.

## Parameters

| Name     | Description                                                     |
| -------- | --------------------------------------------------------------- |
| `Fields` | An ordered set of (name, type) pairs defining the Record shape. |

## Operations

### Get

_[Required][req]._ Returns the value of a named field. Precondition: the field name exists in the Record's schema.

#### Test cases

| Record                        | Field    | Output |
| ----------------------------- | -------- | ------ |
| {name: "Alice", age: 30}      | name     | "Alice"|
| {name: "Alice", age: 30}      | age      | 30     |
| {x: 1, y: 2, z: 3}           | z        | 3      |

### Project

_[Required][req]._ Returns a new Record containing only the specified subset of fields, preserving their relative order. Precondition: all named fields exist in the Record's schema.

#### Test cases

| Record                        | Fields       | Output             |
| ----------------------------- | ------------ | ------------------ |
| {a: 1, b: 2, c: 3}           | [a, c]       | {a: 1, c: 3}      |
| {a: 1, b: 2, c: 3}           | [a, b, c]    | {a: 1, b: 2, c: 3}|
| {a: 1, b: 2, c: 3}           | [b]          | {b: 2}             |

### Extend

_[Required][req]._ Returns a new Record with one or more additional fields appended. If a field name already exists, the new value replaces the previous one.

#### Test cases

| Record              | New Fields      | Output                    |
| ------------------- | --------------- | ------------------------- |
| {a: 1}              | {b: 2}          | {a: 1, b: 2}             |
| {a: 1, b: 2}        | {c: 3}          | {a: 1, b: 2, c: 3}       |
| {a: 1}              | {a: 9}          | {a: 9}                   |
| {a: 1}              | {b: 2, c: 3}    | {a: 1, b: 2, c: 3}       |

### Remove

_[Required][req]._ Returns a new Record with the named field removed. Precondition: the field name exists in the Record's schema.

#### Test cases

| Record                   | Field | Output          |
| ------------------------ | ----- | --------------- |
| {a: 1, b: 2, c: 3}      | b     | {a: 1, c: 3}   |
| {a: 1, b: 2}             | a     | {b: 2}          |
| {x: 10}                  | x     | {}              |

### Rename

_[Required][req]._ Returns a new Record where a single field is given a new name while preserving its value and position. Precondition: the old field name exists in the schema and the new name does not.

#### Test cases

| Record              | Old Name | New Name | Output              |
| ------------------- | -------- | -------- | ------------------- |
| {a: 1, b: 2}        | a        | x        | {x: 1, b: 2}       |
| {name: "A", id: 1}  | name     | label    | {label: "A", id: 1} |

### Merge

_[Required][req]._ Combines two Records into one. Fields from both Records are included. When both Records contain a field with the same name, the value from the second Record is used.

#### Test cases

| Record A         | Record B         | Output                    |
| ---------------- | ---------------- | ------------------------- |
| {a: 1, b: 2}     | {c: 3}           | {a: 1, b: 2, c: 3}       |
| {a: 1}           | {a: 9, b: 2}     | {a: 9, b: 2}             |
| {}               | {a: 1}           | {a: 1}                   |
| {a: 1}           | {}               | {a: 1}                   |

## Type Class Instances

### Equality

Two Records are [Equal][eq-equal] when they share the same schema and every pair of corresponding field values are [Equal][eq-equal]. Precondition: every field type implements [Equality][eq].

[eq]: equality.md
[eq-equal]: equality.md#equal
[req]: ../language.md#required
