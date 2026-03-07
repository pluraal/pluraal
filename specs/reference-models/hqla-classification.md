# HQLA Classification

Classifies financial assets into High Quality Liquid Asset (HQLA) categories, applies regulatory haircuts, and computes a weighted HQLA total. Inspired by the U.S. Liquidity Coverage Ratio regulation (FR 2052a).

The LCR requires banks to maintain sufficient HQLA to cover net cash outflows over a 30-day stress period. This module models the asset-side classification: determining which assets qualify as HQLA, assigning a regulatory haircut, and computing the final weighted value.

## Relational Pipeline

The full regulation operates as a relational pipeline over a table of financial assets:

1. **Filter** unencumbered, non-defaulted assets using [Where](../language/relation.md#where).
2. **Classify** each asset into an HQLA level using [With Column](../language/relation.md#with-column).
3. **Exclude** non-HQLA assets using [Where](../language/relation.md#where).
4. **Join** with the haircut schedule using [Inner Join](../language/relation.md#inner-join) and compute weighted values.
5. **Aggregate** weighted values by level using [Group By](../language/relation.md#group-by).
6. **Apply caps** and compute the final adjusted HQLA total.

The definitions below express each step's row-level logic so that the classification, eligibility, and computation rules can be verified independently.

## Inputs

- `asset_type` — category such as "cash", "treasury", "corporate\_bond", "equity", "other"
- `credit_rating` — external credit rating (e.g., "AAA", "AA", "A", "BBB", "below\_BBB")
- `is_encumbered` — true when the asset is pledged or restricted
- `is_defaulted` — true when the issuer is in default
- `market_value` — current fair market value
- `haircut_rate` — fractional regulatory haircut (e.g., 0.15 for 15%)
- `unadjusted_hqla` — total weighted HQLA before regulatory caps
- `level_2b_total` — weighted total of Level 2B assets

## Definitions

### `is_unencumbered`

Returns [true][bool] when the asset is eligible for HQLA consideration. Encumbered and defaulted assets are excluded.

- [And][and]
  - [Not][not]
    - `is_encumbered`
  - [Not][not]
    - `is_defaulted`

#### Test cases

| `is_encumbered` | `is_defaulted` | `is_unencumbered` |
| --------------- | -------------- | ----------------- |
| false           | false          | true              |
| true            | false          | false             |
| false           | true           | false             |
| true            | true           | false             |

### `hqla_level`

Assigns an HQLA classification level based on asset type and credit rating. The classification rules are: **level\_1** — cash, treasury securities, and sovereign debt with "AAA" or "AA" credit rating; **level\_2a** — corporate bonds with "AA" or "A" credit rating; **level\_2b** — corporate bonds with "BBB" credit rating or equity securities; **non\_hqla** — all other assets.

- [If-Then-Else][ite]
  - [Or][or]
    - [Equal][eq]
      - `asset_type`
      - `"cash"`
    - [And][and]
      - [Equal][eq]
        - `asset_type`
        - `"treasury"`
      - [Or][or]
        - [Equal][eq]
          - `credit_rating`
          - `"AAA"`
        - [Equal][eq]
          - `credit_rating`
          - `"AA"`
  - `"level_1"`
  - [If-Then-Else][ite]
    - [And][and]
      - [Equal][eq]
        - `asset_type`
        - `"corporate_bond"`
      - [Or][or]
        - [Equal][eq]
          - `credit_rating`
          - `"AA"`
        - [Equal][eq]
          - `credit_rating`
          - `"A"`
    - `"level_2a"`
    - [If-Then-Else][ite]
      - [Or][or]
        - [And][and]
          - [Equal][eq]
            - `asset_type`
            - `"corporate_bond"`
          - [Equal][eq]
            - `credit_rating`
            - `"BBB"`
        - [Equal][eq]
          - `asset_type`
          - `"equity"`
      - `"level_2b"`
      - `"non_hqla"`

#### Test cases

| `asset_type`     | `credit_rating` | `hqla_level` |
| ---------------- | --------------- | ------------ |
| "cash"           | "AAA"           | "level_1"    |
| "treasury"       | "AAA"           | "level_1"    |
| "treasury"       | "AA"            | "level_1"    |
| "treasury"       | "A"             | "non_hqla"   |
| "corporate_bond" | "AA"            | "level_2a"   |
| "corporate_bond" | "A"             | "level_2a"   |
| "corporate_bond" | "BBB"           | "level_2b"   |
| "equity"         | "BBB"           | "level_2b"   |
| "other"          | "AAA"           | "non_hqla"   |

### `is_hqla`

Returns [true][bool] when the asset is classified into an HQLA level (level\_1, level\_2a, or level\_2b).

- [Not Equal][neq]
  - `hqla_level`
  - `"non_hqla"`

#### Test cases

| `hqla_level` | `is_hqla` |
| ------------ | --------- |
| "level_1"    | true      |
| "level_2a"   | true      |
| "level_2b"   | true      |
| "non_hqla"   | false     |

### `weighted_value`

Computes the HQLA-weighted value of an asset after applying the regulatory haircut: market\_value × (1 − haircut\_rate).

- [Multiply][mul]
  - `market_value`
  - [Subtract][sub]
    - `1`
    - `haircut_rate`

#### Test cases

| `market_value` | `haircut_rate` | `weighted_value` |
| -------------- | -------------- | ---------------- |
| 1000           | 0              | 1000             |
| 600            | 0.15           | 510              |
| 400            | 0.50           | 200              |
| 0              | 0.15           | 0                |

### `level_2b_cap`

Under the US LCR, Level 2B assets may not exceed 15% of total HQLA. This computes the maximum allowable Level 2B value.

- [Multiply][mul]
  - `unadjusted_hqla`
  - `0.15`

#### Test cases

| `unadjusted_hqla` | `level_2b_cap` |
| ------------------ | -------------- |
| 1710               | 256.5          |
| 1000               | 150            |
| 0                  | 0              |

### `level_2b_excess`

Amount by which Level 2B exceeds the regulatory cap. Zero when Level 2B is within the cap.

- [If-Then-Else][ite]
  - [Greater Than][gt]
    - `level_2b_total`
    - `level_2b_cap`
  - [Subtract][sub]
    - `level_2b_total`
    - `level_2b_cap`
  - `0`

#### Test cases

| `level_2b_total` | `level_2b_cap` | `level_2b_excess` |
| ----------------- | -------------- | ------------------ |
| 200               | 256.5          | 0                  |
| 300               | 150            | 150                |
| 0                 | 150            | 0                  |

### `adjusted_hqla`

Total HQLA after applying the Level 2B cap.

- [Subtract][sub]
  - `unadjusted_hqla`
  - `level_2b_excess`

#### Test cases

| `unadjusted_hqla` | `level_2b_excess` | `adjusted_hqla` |
| ------------------ | ----------------- | ---------------- |
| 1710               | 0                 | 1710             |
| 1000               | 150               | 850              |
| 0                  | 0                 | 0                |

[and]: ../language/boolean.md#and
[bool]: ../language/boolean.md
[eq]: ../language/equality.md#equal
[gt]: ../language/ordering.md#greater-than
[ite]: ../language/boolean.md#if-then-else
[mul]: ../language/number.md#multiplication
[neq]: ../language/equality.md#not-equal
[not]: ../language/boolean.md#not
[or]: ../language/boolean.md#or
[sub]: ../language/number.md#subtraction
