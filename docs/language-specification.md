## Data

### Literals

## Logic

### Variables

### Branching Out

#### If-then-else

```json
{
  "if": "condition",
  "then": "condition is true",
  "else": "condition is false"
}
```

##### Chaining

```json
{
  "rules": [
    { "when": "condition 1", "then": "rule 1 matched" },
    { "when": "condition 2", "then": "rule 1 did not match, rule 2 matched" }
  ],
  "otherwise": "no rule matched"
}
```

#### Finite branches

```json
{
  "branchOn": "expression",
  "when": {
    "A": "Case A",
    "B": "Case B"
  },
  "otherwise": {}
}
```

## Types

## Modules

## Packages
