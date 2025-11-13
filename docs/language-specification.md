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

### Scopes

Scopes provide typed inputs and named calculations for complex computations.

#### Structure

```json
{
  "inputs": [
    { "name": "inputName", "type": "string|number|bool" }
  ],
  "calculations": {
    "calculationName": "expression"
  ],
  "result": "expression"
}
```

#### Example

```json
{
  "inputs": [
    { "name": "radius", "type": "number" },
    { "name": "pi", "type": "number" }
  ],
  "calculations": {
    "area": {
      "if": true,
      "then": 78.54,
      "else": 0
    }
  },
  "result": "area"
}
```

#### Type System

- `string`: String literal values
- `number`: Numeric literal values  
- `bool`: Boolean literal values

#### Evaluation Order

1. Validate all inputs are present and have correct types
2. Evaluate calculations (each can reference previous calculations)
3. Evaluate the result expression with the extended context

## Types

## Modules

## Packages
