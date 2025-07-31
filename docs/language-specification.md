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

Scopes provide typed inputs and calculated data points for complex computations.

#### Structure

```json
{
  "inputs": [
    { "name": "inputName", "type": "string|number|bool" }
  ],
  "dataPoints": [
    { "name": "dataPointName", "expression": "expression" }
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
  "dataPoints": [
    { 
      "name": "area", 
      "expression": {
        "if": true,
        "then": 78.54,
        "else": 0
      }
    }
  ],
  "result": "area"
}
```

#### Type System

- `string`: String literal values
- `number`: Numeric literal values  
- `bool`: Boolean literal values

#### Evaluation Order

1. Validate all inputs are present and have correct types
2. Calculate data points in order (each can reference previous data points)
3. Evaluate the result expression with the extended context

## Types

## Modules

## Packages
