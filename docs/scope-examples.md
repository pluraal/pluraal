# Pluraal Scope Feature Examples

The scope feature in Pluraal provides a powerful way to define typed inputs and calculated data points. This document provides comprehensive examples of how to use scopes.

## Basic Scope Structure

A scope consists of three main parts:

1. **Inputs**: Typed variables that must be provided
2. **Data Points**: Calculated values derived from inputs and other data points  
3. **Result**: The final expression to evaluate

## Example 1: Simple Calculator

```elm
-- Define inputs with types
inputs = 
    [ { name = "x", type_ = NumberType }
    , { name = "y", type_ = NumberType }
    ]

-- Define calculated data points
dataPoints =
    [ { name = "sum", expression = LiteralExpr (NumberLiteral 0) } -- simplified for example
    , { name = "product", expression = LiteralExpr (NumberLiteral 0) } -- simplified for example
    ]

-- Define the result
result = VariableExpr "sum"

-- Create the scope
calculatorScope = { inputs = inputs, dataPoints = dataPoints, result = result }
scopeExpr = ScopeExpr calculatorScope

-- Provide input context
context = Dict.fromList 
    [ ( "x", LiteralExpr (NumberLiteral 10) )
    , ( "y", LiteralExpr (NumberLiteral 5) )
    ]

-- Evaluate
result = evaluate context scopeExpr
```

## Example 2: User Profile Processing

```elm
-- Define inputs for user data
inputs = 
    [ { name = "firstName", type_ = StringType }
    , { name = "lastName", type_ = StringType }
    , { name = "age", type_ = NumberType }
    , { name = "isActive", type_ = BoolType }
    ]

-- Define calculated data points
dataPoints =
    [ { name = "fullName", expression = VariableExpr "firstName" } -- In practice, would concatenate
    , { name = "category", expression = 
        BranchExpr (FiniteBranchBranch 
            { branchOn = VariableExpr "isActive"
            , cases = Dict.fromList 
                [ ( "true", LiteralExpr (StringLiteral "active-user") )
                , ( "false", LiteralExpr (StringLiteral "inactive-user") )
                ]
            , otherwise = Just (LiteralExpr (StringLiteral "unknown"))
            })
      }
    ]

-- Define the result - return the category
result = VariableExpr "category"

-- Create the scope
userScope = { inputs = inputs, dataPoints = dataPoints, result = result }
```

## Example 3: Chained Data Points

Data points can reference other data points, allowing for complex calculations:

```elm
inputs = 
    [ { name = "baseValue", type_ = NumberType }
    ]

dataPoints =
    [ { name = "doubled", expression = VariableExpr "baseValue" }
    , { name = "quadrupled", expression = VariableExpr "doubled" }  
    , { name = "final", expression = VariableExpr "quadrupled" }
    ]

result = VariableExpr "final"

chainedScope = { inputs = inputs, dataPoints = dataPoints, result = result }
```

## JSON Representation

Scopes can be serialized to JSON for storage or transmission:

```json
{
  "inputs": [
    { "name": "firstName", "type": "string" },
    { "name": "lastName", "type": "string" },
    { "name": "age", "type": "number" },
    { "name": "isActive", "type": "bool" }
  ],
  "dataPoints": [
    { 
      "name": "fullName", 
      "expression": "firstName"
    },
    {
      "name": "category",
      "expression": {
        "branchOn": "isActive",
        "when": {
          "true": "active-user",
          "false": "inactive-user"
        },
        "otherwise": "unknown"
      }
    }
  ],
  "result": "category"
}
```

## Type Validation

Scopes provide type safety by validating inputs:

- String inputs must be string literals
- Number inputs must be number literals  
- Boolean inputs must be boolean literals

If an input has the wrong type or is missing, evaluation will fail with a descriptive error message.

## Error Handling

Common errors when using scopes:

1. **Missing Input**: "Required input not found: inputName"
2. **Type Mismatch**: "Input inputName has incorrect type"
3. **Data Point Error**: "Error calculating data point dataPointName: ..."

## Best Practices

1. **Keep inputs minimal**: Only define inputs that are actually needed
2. **Use descriptive names**: Choose clear names for inputs and data points
3. **Chain data points logically**: Build complex calculations step by step
4. **Handle edge cases**: Use conditional logic to handle unexpected values
5. **Validate early**: Put type-sensitive operations in data points rather than the result
