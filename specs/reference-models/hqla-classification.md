# HQLA Classification

Classifies financial assets into High Quality Liquid Asset (HQLA) categories, applies regulatory haircuts, and computes a weighted HQLA total. Inspired by the U.S. Liquidity Coverage Ratio regulation (FR 2052a).

The LCR requires banks to maintain sufficient HQLA to cover net cash outflows over a 30-day stress period. This module models the asset-side classification: determining which assets qualify as HQLA, assigning a regulatory haircut, and computing the final weighted value.

## Inputs

- `assets` — a [Relation](../language/relation.md) of financial assets with the following schema:

| Field             | Type                                      | Description                              |
| ----------------- | ----------------------------------------- | ---------------------------------------- |
| `asset_id`        | [Text](../language/text.md)               | Unique identifier for the asset.         |
| `asset_type`      | [Text](../language/text.md)               | Category such as "cash", "treasury", "corporate_bond", "equity", "other". |
| `market_value`    | [Decimal](../language/decimal.md)         | Current fair market value.               |
| `is_encumbered`   | [Boolean](../language/boolean.md)         | True when the asset is pledged or restricted. |
| `is_defaulted`    | [Boolean](../language/boolean.md)         | True when the issuer is in default.      |
| `credit_rating`   | [Text](../language/text.md)               | External credit rating (e.g., "AAA", "AA", "A", "BBB", "below_BBB"). |
| `maturity_days`   | [Integer](../language/integer.md)         | Days until maturity from the reporting date. |

- `haircut_schedule` — a [Relation](../language/relation.md) providing the regulatory haircut for each HQLA level:

| Field          | Type                                  | Description                                  |
| -------------- | ------------------------------------- | -------------------------------------------- |
| `hqla_level`   | [Text](../language/text.md)           | HQLA classification level.                   |
| `haircut_rate` | [Decimal](../language/decimal.md)     | Fractional haircut (e.g., 0.15 for 15%).     |

Default schedule:

| `hqla_level` | `haircut_rate` |
| ------------- | -------------- |
| "level_1"     | 0              |
| "level_2a"    | 0.15           |
| "level_2b"    | 0.50           |

## Definitions

### `unencumbered_assets`

Assets eligible for HQLA consideration. Encumbered and defaulted assets are excluded.

- [Where](../language/relation.md#where)
  - `assets`
  - [And](../language/boolean.md#and)
    - [Not](../language/boolean.md#not)
      - `is_encumbered`
    - [Not](../language/boolean.md#not)
      - `is_defaulted`

#### Test cases

| `asset_id` | `asset_type` | `market_value` | `is_encumbered` | `is_defaulted` | `credit_rating` | `maturity_days` | in `unencumbered_assets` |
| ---------- | ------------ | -------------- | --------------- | -------------- | --------------- | --------------- | ------------------------ |
| "A1"       | "treasury"   | 1000           | false           | false          | "AAA"           | 30              | true                     |
| "A2"       | "treasury"   | 500            | true            | false          | "AAA"           | 60              | false                    |
| "A3"       | "equity"     | 200            | false           | true           | "BBB"           | 90              | false                    |
| "A4"       | "cash"       | 800            | false           | false          | "AAA"           | 0               | true                     |

### `classified_assets`

Each unencumbered asset is assigned an HQLA level based on its asset type and credit rating. The classification rules are:

- **level_1**: cash, treasury securities, and sovereign debt with "AAA" or "AA" credit rating.
- **level_2a**: agency securities and corporate bonds with "AA" or "A" credit rating.
- **level_2b**: corporate bonds with "BBB" credit rating and equity securities included in a major index.
- **non_hqla**: all other assets.

- [With Column](../language/relation.md#with-column)
  - `unencumbered_assets`
  - `hqla_level`
  - [If-Then-Else](../language/boolean.md#if-then-else)
    - [Or](../language/boolean.md#or)
      - [Equal](../language/equality.md#equal)
        - `asset_type`
        - `"cash"`
      - [And](../language/boolean.md#and)
        - [Equal](../language/equality.md#equal)
          - `asset_type`
          - `"treasury"`
        - [Or](../language/boolean.md#or)
          - [Equal](../language/equality.md#equal)
            - `credit_rating`
            - `"AAA"`
          - [Equal](../language/equality.md#equal)
            - `credit_rating`
            - `"AA"`
    - `"level_1"`
    - [If-Then-Else](../language/boolean.md#if-then-else)
      - [And](../language/boolean.md#and)
        - [Equal](../language/equality.md#equal)
          - `asset_type`
          - `"corporate_bond"`
        - [Or](../language/boolean.md#or)
          - [Equal](../language/equality.md#equal)
            - `credit_rating`
            - `"AA"`
          - [Equal](../language/equality.md#equal)
            - `credit_rating`
            - `"A"`
      - `"level_2a"`
      - [If-Then-Else](../language/boolean.md#if-then-else)
        - [Or](../language/boolean.md#or)
          - [And](../language/boolean.md#and)
            - [Equal](../language/equality.md#equal)
              - `asset_type`
              - `"corporate_bond"`
            - [Equal](../language/equality.md#equal)
              - `credit_rating`
              - `"BBB"`
          - [Equal](../language/equality.md#equal)
            - `asset_type`
            - `"equity"`
        - `"level_2b"`
        - `"non_hqla"`

#### Test cases

| `asset_type`      | `credit_rating` | `hqla_level` |
| ----------------- | --------------- | ------------ |
| "cash"            | "AAA"           | "level_1"    |
| "treasury"        | "AAA"           | "level_1"    |
| "treasury"        | "AA"            | "level_1"    |
| "treasury"        | "A"             | "non_hqla"   |
| "corporate_bond"  | "AA"            | "level_2a"   |
| "corporate_bond"  | "A"             | "level_2a"   |
| "corporate_bond"  | "BBB"           | "level_2b"   |
| "equity"          | "BBB"           | "level_2b"   |
| "other"           | "AAA"           | "non_hqla"   |

### `hqla_only`

Only assets classified into an HQLA level (level\_1, level\_2a, or level\_2b) are retained.

- [Where](../language/relation.md#where)
  - `classified_assets`
  - [Not Equal](../language/equality.md#not-equal)
    - `hqla_level`
    - `"non_hqla"`

#### Test cases

| `asset_id` | `hqla_level` | in `hqla_only` |
| ---------- | ------------ | --------------- |
| "A1"       | "level_1"    | true            |
| "A5"       | "level_2a"   | true            |
| "A6"       | "level_2b"   | true            |
| "A7"       | "non_hqla"   | false           |

### `haircut_applied`

Each qualifying asset is joined to the haircut schedule, and a weighted value is computed as market\_value × (1 − haircut\_rate).

- [With Column](../language/relation.md#with-column)
  - [Inner Join](../language/relation.md#inner-join)
    - `hqla_only`
    - `haircut_schedule`
    - [Equal](../language/equality.md#equal)
      - `hqla_level`
      - `hqla_level`
  - `weighted_value`
  - [Multiply][mul]
    - `market_value`
    - [Subtract](../language/number.md#subtraction)
      - `1`
      - `haircut_rate`

#### Test cases

| `asset_id` | `market_value` | `hqla_level` | `haircut_rate` | `weighted_value` |
| ---------- | -------------- | ------------ | -------------- | ---------------- |
| "A1"       | 1000           | "level_1"    | 0              | 1000             |
| "A5"       | 600            | "level_2a"   | 0.15           | 510              |
| "A6"       | 400            | "level_2b"   | 0.50           | 200              |

### `totals_by_level`

Weighted values aggregated by HQLA level.

- [Group By](../language/relation.md#group-by)
  - `haircut_applied`
  - `hqla_level`
  - [Sum](../language/relation.md#sum) of `weighted_value` as `level_total`

#### Test cases

| `hqla_level` | `level_total` |
| ------------- | ------------- |
| "level_1"     | 1000          |
| "level_2a"    | 510           |
| "level_2b"    | 200           |

### `unadjusted_hqla`

Sum of all weighted values before regulatory caps.

- [Sum](../language/relation.md#sum)
  - `totals_by_level`
  - `level_total`

#### Test cases

| `level_total` values    | `unadjusted_hqla` |
| ----------------------- | ------------------ |
| [1000, 510, 200]        | 1710               |
| [500]                   | 500                |
| []                      | 0                  |

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

### `level_2b_total`

Actual weighted Level 2B total from the aggregation.

- [Get](../language/record.md#get)
  - [Where](../language/relation.md#where)
    - `totals_by_level`
    - [Equal](../language/equality.md#equal)
      - `hqla_level`
      - `"level_2b"`
  - `level_total`

#### Test cases

| `totals_by_level`                                                           | `level_2b_total` |
| --------------------------------------------------------------------------- | ---------------- |
| [{hqla_level: "level_1", level_total: 1000}, {hqla_level: "level_2b", level_total: 200}] | 200              |

### `level_2b_excess`

Amount by which Level 2B exceeds the regulatory cap. Zero when Level 2B is within the cap.

- [If-Then-Else](../language/boolean.md#if-then-else)
  - [Greater Than](../language/ordering.md#greater-than)
    - `level_2b_total`
    - `level_2b_cap`
  - [Subtract](../language/number.md#subtraction)
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

- [Subtract](../language/number.md#subtraction)
  - `unadjusted_hqla`
  - `level_2b_excess`

#### Test cases

| `unadjusted_hqla` | `level_2b_excess` | `adjusted_hqla` |
| ------------------ | ----------------- | ---------------- |
| 1710               | 0                 | 1710             |
| 1000               | 150               | 850              |
| 0                  | 0                 | 0                |

[mul]: ../language/number.md#multiplication
