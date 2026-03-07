# Relation

## Overview

A Relation is a parametric type over a [Record][rec] type `R` that holds zero or more records sharing the same schema. It is the primary structure for tabular data — analogous to a table in SQL, a `DataFrame` in Apache Spark, and a `DataFrame` / `LazyFrame` in Polars.

A Relation is a specialized [Collection](collection.md) whose element type is constrained to be a [Record][rec]. It inherits Collection operations such as [Size](collection.md#size), [Filter](collection.md#filter), and [Is Empty](collection.md#is-empty), while adding relational operations for column projection, joining, grouping, and aggregation.

## Parameters

| Name | Description                                           |
| ---- | ----------------------------------------------------- |
| `R`  | The [Record][rec] type shared by all rows.            |

## Attributes

### Schema

The schema is the ordered list of (field-name, field-type) pairs inherited from the Record type `R`. All rows in the Relation conform to this schema.

## Column Operations

### Select

_[Required][req]._ Returns a new Relation whose rows contain only the named fields. This is column projection — analogous to `SELECT col1, col2` in SQL, `select` in Spark, and `select` in Polars.

Precondition: all named fields exist in the schema.

#### Test cases

| Relation                                             | Fields   | Output                           |
| ---------------------------------------------------- | -------- | -------------------------------- |
| [{a: 1, b: 2}, {a: 3, b: 4}]                        | [a]      | [{a: 1}, {a: 3}]                |
| [{a: 1, b: 2, c: 3}]                                 | [a, c]   | [{a: 1, c: 3}]                  |
| []                                                   | [a]      | []                               |

### With Column

_[Required][req]._ Returns a new Relation with an additional or replaced column whose value is computed by applying an expression to each row. Analogous to `withColumn` in Spark and `with_columns` in Polars.

If the column name already exists, the existing column is replaced. Otherwise, the column is appended.

#### Test cases

| Relation                          | Column  | Expression            | Output                                  |
| --------------------------------- | ------- | --------------------- | --------------------------------------- |
| [{a: 1, b: 2}, {a: 3, b: 4}]     | c       | a + b                 | [{a: 1, b: 2, c: 3}, {a: 3, b: 4, c: 7}] |
| [{x: 10}, {x: 20}]                | y       | x * 2                 | [{x: 10, y: 20}, {x: 20, y: 40}]       |
| [{a: 5, b: 3}]                    | a       | a + 1                 | [{a: 6, b: 3}]                          |
| []                                | c       | a + b                 | []                                      |

### Rename Column

_[Required][req]._ Returns a new Relation with a single column renamed. Analogous to `withColumnRenamed` in Spark and `rename` in Polars. Precondition: the old column name exists and the new name does not.

#### Test cases

| Relation                      | Old Name | New Name | Output                        |
| ----------------------------- | -------- | -------- | ----------------------------- |
| [{a: 1, b: 2}]                | a        | x        | [{x: 1, b: 2}]               |
| [{a: 1, b: 2}, {a: 3, b: 4}] | b        | y        | [{a: 1, y: 2}, {a: 3, y: 4}] |

### Drop Column

_[Required][req]._ Returns a new Relation with the named column removed. Precondition: the column exists in the schema.

#### Test cases

| Relation                          | Column | Output                 |
| --------------------------------- | ------ | ---------------------- |
| [{a: 1, b: 2, c: 3}]              | b      | [{a: 1, c: 3}]        |
| [{a: 1, b: 2}, {a: 3, b: 4}]     | a      | [{b: 2}, {b: 4}]      |

## Row Operations

### Where

_[Required][req]._ Returns a new Relation containing only rows for which the predicate returns [Boolean][bool] `true`. Analogous to `WHERE` in SQL, `filter`/`where` in Spark, and `filter` in Polars.

#### Test cases

| Relation                                    | Predicate    | Output                     |
| ------------------------------------------- | ------------ | -------------------------- |
| [{a: 1, b: 2}, {a: 3, b: 4}, {a: 5, b: 6}] | a > 2        | [{a: 3, b: 4}, {a: 5, b: 6}] |
| [{a: 1}, {a: 2}, {a: 3}]                    | a > 5        | []                         |
| []                                          | a > 0        | []                         |

### Distinct

_[Required][req]._ Returns a new Relation with duplicate rows removed. Two rows are duplicates when all corresponding field values are [Equal][eq-equal]. Analogous to `SELECT DISTINCT` in SQL, `distinct` in Spark, and `unique` in Polars.

#### Test cases

| Relation                                    | Output                       |
| ------------------------------------------- | ---------------------------- |
| [{a: 1, b: 2}, {a: 1, b: 2}, {a: 3, b: 4}] | [{a: 1, b: 2}, {a: 3, b: 4}] |
| [{a: 1}, {a: 2}]                            | [{a: 1}, {a: 2}]            |
| []                                          | []                           |

### Order By

_[Required][req]._ Returns a new Relation with rows sorted by one or more column expressions. Each column expression has an ascending or descending direction. Ties on the first column are broken by subsequent columns. Analogous to `ORDER BY` in SQL, `orderBy` in Spark, and `sort` in Polars.

#### Test cases

| Relation                                            | Order          | Output                                          |
| --------------------------------------------------- | -------------- | ------------------------------------------------ |
| [{a: 3}, {a: 1}, {a: 2}]                            | a ascending    | [{a: 1}, {a: 2}, {a: 3}]                        |
| [{a: 1, b: 2}, {a: 1, b: 1}]                        | a asc, b asc   | [{a: 1, b: 1}, {a: 1, b: 2}]                    |
| [{a: 3}, {a: 1}, {a: 2}]                            | a descending   | [{a: 3}, {a: 2}, {a: 1}]                        |
| []                                                  | a ascending    | []                                               |

### Limit

_[Required][req]._ Returns a new Relation containing at most the first `n` rows. Analogous to `LIMIT` in SQL, `limit` in Spark, and `head`/`limit` in Polars. Precondition: `n` ≥ 0.

#### Test cases

| Relation                          | n | Output                 |
| --------------------------------- | - | ---------------------- |
| [{a: 1}, {a: 2}, {a: 3}]          | 2 | [{a: 1}, {a: 2}]      |
| [{a: 1}, {a: 2}]                  | 5 | [{a: 1}, {a: 2}]      |
| [{a: 1}, {a: 2}]                  | 0 | []                     |
| []                                | 3 | []                     |

## Set Operations

### Union

_[Required][req]._ Returns a new Relation containing all rows from both operands. Does not remove duplicates. Precondition: both Relations share the same schema. Analogous to `UNION ALL` in SQL, `union`/`unionAll` in Spark, and `concat` in Polars.

#### Test cases

| Relation A                    | Relation B                    | Output                                      |
| ----------------------------- | ----------------------------- | ------------------------------------------- |
| [{a: 1}]                      | [{a: 2}]                      | [{a: 1}, {a: 2}]                            |
| [{a: 1}]                      | [{a: 1}]                      | [{a: 1}, {a: 1}]                            |
| []                            | [{a: 1}]                      | [{a: 1}]                                    |
| [{a: 1}]                      | []                            | [{a: 1}]                                    |

### Intersect

_[Required][req]._ Returns a new Relation containing rows that appear in both operands, removing duplicates from the result. Precondition: both Relations share the same schema. Analogous to `INTERSECT` in SQL.

#### Test cases

| Relation A                         | Relation B                         | Output               |
| ---------------------------------- | ---------------------------------- | -------------------- |
| [{a: 1}, {a: 2}, {a: 3}]           | [{a: 2}, {a: 3}, {a: 4}]           | [{a: 2}, {a: 3}]    |
| [{a: 1}]                           | [{a: 2}]                           | []                   |
| []                                 | [{a: 1}]                           | []                   |

### Except

_[Required][req]._ Returns a new Relation containing rows from the first operand that do not appear in the second, removing duplicates from the result. Precondition: both Relations share the same schema. Analogous to `EXCEPT` in SQL, `except`/`subtract` in Spark.

#### Test cases

| Relation A                         | Relation B                         | Output               |
| ---------------------------------- | ---------------------------------- | -------------------- |
| [{a: 1}, {a: 2}, {a: 3}]           | [{a: 2}]                           | [{a: 1}, {a: 3}]    |
| [{a: 1}]                           | [{a: 1}]                           | []                   |
| [{a: 1}]                           | []                                 | [{a: 1}]             |
| []                                 | [{a: 1}]                           | []                   |

## Join Operations

### Inner Join

_[Required][req]._ Returns a new Relation containing the [Merge][merge] of each pair of rows — one from each operand — for which the join condition returns [Boolean][bool] `true`. Rows that have no match in the other Relation are excluded. Analogous to `INNER JOIN` in SQL, `join` in Spark, and `join` in Polars.

#### Test cases

| Left                              | Right                             | Condition       | Output                                       |
| --------------------------------- | --------------------------------- | --------------- | -------------------------------------------- |
| [{a: 1, b: "x"}, {a: 2, b: "y"}] | [{a: 2, c: 10}, {a: 3, c: 20}]   | left.a = right.a | [{a: 2, b: "y", c: 10}]                     |
| [{a: 1}]                          | [{b: 2}]                          | true            | [{a: 1, b: 2}]                              |
| [{a: 1}]                          | [{a: 2}]                          | left.a = right.a | []                                           |
| []                                | [{a: 1}]                          | true            | []                                           |

### Left Join

_[Required][req]._ Returns a new Relation containing the [Merge][merge] of each row from the left operand with matching rows from the right. When a left row has no match, the right-side fields are filled with [Optional][opt] **none**. Analogous to `LEFT OUTER JOIN` in SQL, `join(..., "left")` in Spark, and `join(..., how="left")` in Polars.

#### Test cases

| Left                              | Right                             | Condition       | Output                                                        |
| --------------------------------- | --------------------------------- | --------------- | ------------------------------------------------------------- |
| [{a: 1}, {a: 2}]                  | [{a: 2, b: 10}]                   | left.a = right.a | [{a: 1, b: none}, {a: 2, b: 10}]                            |
| [{a: 1}]                          | []                                | left.a = right.a | [{a: 1, b: none}]                                           |
| []                                | [{a: 1, b: 10}]                   | left.a = right.a | []                                                           |

### Right Join

_[Required][req]._ Returns a new Relation containing the [Merge][merge] of each row from the right operand with matching rows from the left. When a right row has no match, the left-side fields are filled with [Optional][opt] **none**. Analogous to `RIGHT OUTER JOIN` in SQL. Semantically equivalent to a [Left Join](#left-join) with operands swapped.

#### Test cases

| Left                              | Right                             | Condition       | Output                                                        |
| --------------------------------- | --------------------------------- | --------------- | ------------------------------------------------------------- |
| [{a: 1, b: 10}]                   | [{a: 1}, {a: 2}]                  | left.a = right.a | [{a: 1, b: 10}, {a: 2, b: none}]                            |
| []                                | [{a: 1}]                          | left.a = right.a | [{a: 1, b: none}]                                           |

### Full Join

_[Required][req]._ Returns a new Relation containing all rows from both operands. When a row from either side has no match, the fields from the other side are filled with [Optional][opt] **none**. Analogous to `FULL OUTER JOIN` in SQL.

#### Test cases

| Left                   | Right                  | Condition       | Output                                                    |
| ---------------------- | ---------------------- | --------------- | --------------------------------------------------------- |
| [{a: 1}]               | [{a: 2}]               | left.a = right.a | [{a: 1, b: none}, {a: 2, b: none}]                      |
| [{a: 1}]               | [{a: 1, b: 10}]        | left.a = right.a | [{a: 1, b: 10}]                                         |
| []                     | [{a: 1}]               | left.a = right.a | [{a: 1, b: none}]                                       |

### Cross Join

_[Required][req]._ Returns a new Relation containing the [Merge][merge] of every row from the left operand with every row from the right operand (Cartesian product). No join condition is required. Analogous to `CROSS JOIN` in SQL, `crossJoin` in Spark, and `join(..., how="cross")` in Polars.

#### Test cases

| Left                   | Right              | Output                                                              |
| ---------------------- | ------------------ | ------------------------------------------------------------------- |
| [{a: 1}, {a: 2}]       | [{b: 10}, {b: 20}] | [{a: 1, b: 10}, {a: 1, b: 20}, {a: 2, b: 10}, {a: 2, b: 20}]     |
| [{a: 1}]               | [{b: 10}]          | [{a: 1, b: 10}]                                                    |
| []                     | [{b: 10}]          | []                                                                  |
| [{a: 1}]               | []                 | []                                                                  |

## Aggregation Operations

### Group By

_[Required][req]._ Partitions the Relation into groups sharing equal values for one or more key columns, then applies one or more aggregate expressions to each group. Returns a new Relation with one row per group containing the key columns and aggregate results. Analogous to `GROUP BY` in SQL, `groupBy` in Spark, and `group_by` in Polars.

#### Test cases

| Relation                                                    | Keys | Aggregates       | Output                                     |
| ----------------------------------------------------------- | ---- | ---------------- | ------------------------------------------ |
| [{k: "a", v: 1}, {k: "b", v: 2}, {k: "a", v: 3}]          | [k]  | sum(v) as total  | [{k: "a", total: 4}, {k: "b", total: 2}]  |
| [{k: "a", v: 10}, {k: "a", v: 20}]                          | [k]  | count(v) as n    | [{k: "a", n: 2}]                           |
| []                                                          | [k]  | sum(v) as total  | []                                         |

### Count

_[Required][req]._ Returns the number of rows in the Relation as an [Integer][int]. Analogous to `COUNT(*)` in SQL.

#### Test cases

| Relation                          | Output |
| --------------------------------- | ------ |
| [{a: 1}, {a: 2}, {a: 3}]          | 3      |
| [{a: 1}]                          | 1      |
| []                                | 0      |

### Sum

_[Required][req]._ Returns the total of a numeric column across all rows. Precondition: the column type implements [Number][num]. Returns zero when the Relation is empty. Analogous to `SUM(col)` in SQL.

#### Test cases

| Relation                          | Column | Output |
| --------------------------------- | ------ | ------ |
| [{a: 1}, {a: 2}, {a: 3}]          | a      | 6      |
| [{a: 10}]                         | a      | 10     |
| []                                | a      | 0      |

### Average

_[Derived][der]._ Returns the arithmetic mean of a numeric column. Precondition: the column type implements [Number][num]; the Relation is non-empty. Defined as [Sum](#sum) of the column divided by [Count](#count). Analogous to `AVG(col)` in SQL.

#### Test cases

| Relation                          | Column | Output |
| --------------------------------- | ------ | ------ |
| [{a: 2}, {a: 4}]                  | a      | 3      |
| [{a: 1}, {a: 2}, {a: 3}]          | a      | 2      |
| [{a: 10}]                         | a      | 10     |

### Min

_[Required][req]._ Returns the minimum value of a column. Precondition: the column type implements [Ordering][ord]; the Relation is non-empty. Analogous to `MIN(col)` in SQL.

#### Test cases

| Relation                          | Column | Output |
| --------------------------------- | ------ | ------ |
| [{a: 3}, {a: 1}, {a: 2}]          | a      | 1      |
| [{a: 5}]                          | a      | 5      |

### Max

_[Required][req]._ Returns the maximum value of a column. Precondition: the column type implements [Ordering][ord]; the Relation is non-empty. Analogous to `MAX(col)` in SQL.

#### Test cases

| Relation                          | Column | Output |
| --------------------------------- | ------ | ------ |
| [{a: 3}, {a: 1}, {a: 2}]          | a      | 3      |
| [{a: 5}]                          | a      | 5      |

### Count Distinct

_[Derived][der]._ Returns the number of distinct values in a column. Precondition: the column type implements [Equality][eq]. Defined as [Count](#count) after applying [Distinct](#distinct) on the projected column. Analogous to `COUNT(DISTINCT col)` in SQL, `countDistinct` in Spark, and `n_unique` in Polars.

#### Test cases

| Relation                                    | Column | Output |
| ------------------------------------------- | ------ | ------ |
| [{a: 1}, {a: 2}, {a: 1}, {a: 3}]            | a      | 3      |
| [{a: 1}, {a: 1}]                            | a      | 1      |
| []                                          | a      | 0      |

## Window Operations

### Window

_[Required][req]._ Applies an aggregate or ranking function over a sliding window defined by a partition key and an ordering expression. Each row receives an additional column with the window function result. The window function is evaluated for each row over the set of rows sharing the same partition key, ordered by the ordering expression. Analogous to window functions in SQL (`OVER (PARTITION BY ... ORDER BY ...)`), `Window` in Spark, and `over` in Polars.

#### Test cases

| Relation                                                    | Partition | Order | Function       | New Column | Output                                                                                |
| ----------------------------------------------------------- | --------- | ----- | -------------- | ---------- | ------------------------------------------------------------------------------------- |
| [{d: "A", v: 1}, {d: "A", v: 2}, {d: "B", v: 3}]           | d         | v asc | running sum(v) | cumulative | [{d: "A", v: 1, cumulative: 1}, {d: "A", v: 2, cumulative: 3}, {d: "B", v: 3, cumulative: 3}] |

### Row Number

_[Derived][der]._ Assigns a sequential [Integer][int] starting at 1 to each row within its partition, ordered by the given expression. Defined in terms of [Window](#window) with a counting function. Analogous to `ROW_NUMBER()` in SQL.

#### Test cases

| Relation                                        | Partition | Order | Output                                                          |
| ----------------------------------------------- | --------- | ----- | --------------------------------------------------------------- |
| [{d: "A", v: 3}, {d: "A", v: 1}, {d: "B", v: 2}] | d         | v asc | [{d: "A", v: 1, row_num: 1}, {d: "A", v: 3, row_num: 2}, {d: "B", v: 2, row_num: 1}] |

### Rank

_[Derived][der]._ Assigns a rank to each row within its partition based on the ordering expression. Rows with equal ordering values receive the same rank; subsequent ranks skip accordingly (e.g., 1, 1, 3). Defined in terms of [Window](#window). Analogous to `RANK()` in SQL.

#### Test cases

| Relation                                                    | Partition | Order | Output                                                                                    |
| ----------------------------------------------------------- | --------- | ----- | ----------------------------------------------------------------------------------------- |
| [{d: "A", v: 1}, {d: "A", v: 1}, {d: "A", v: 3}]           | d         | v asc | [{d: "A", v: 1, rank: 1}, {d: "A", v: 1, rank: 1}, {d: "A", v: 3, rank: 3}]            |

### Lag

_[Required][req]._ Returns the value of a column from the row that is a given number of rows before the current row within the partition and ordering. Returns [Optional][opt] **none** when no such row exists. Analogous to `LAG()` in SQL.

#### Test cases

| Relation                                        | Partition | Order | Column | Offset | Output                                                          |
| ----------------------------------------------- | --------- | ----- | ------ | ------ | --------------------------------------------------------------- |
| [{d: "A", v: 10}, {d: "A", v: 20}, {d: "A", v: 30}] | d   | v asc | v      | 1      | [{d: "A", v: 10, lag_v: none}, {d: "A", v: 20, lag_v: 10}, {d: "A", v: 30, lag_v: 20}] |

### Lead

_[Required][req]._ Returns the value of a column from the row that is a given number of rows after the current row within the partition and ordering. Returns [Optional][opt] **none** when no such row exists. Analogous to `LEAD()` in SQL.

#### Test cases

| Relation                                        | Partition | Order | Column | Offset | Output                                                             |
| ----------------------------------------------- | --------- | ----- | ------ | ------ | ------------------------------------------------------------------ |
| [{d: "A", v: 10}, {d: "A", v: 20}, {d: "A", v: 30}] | d   | v asc | v      | 1      | [{d: "A", v: 10, lead_v: 20}, {d: "A", v: 20, lead_v: 30}, {d: "A", v: 30, lead_v: none}] |

## Type Class Instances

Relation does not itself implement a type class. The applicability of individual operations depends on the Record type's field types and their type class instances, as stated in each operation's preconditions.

[bool]: boolean.md
[der]: ../language.md#derived
[eq]: equality.md
[eq-equal]: equality.md#equal
[int]: integer.md
[merge]: record.md#merge
[num]: number.md
[opt]: optional.md
[ord]: ordering.md
[rec]: record.md
[req]: ../language.md#required
