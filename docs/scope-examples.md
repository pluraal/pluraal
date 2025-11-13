# Pluraal Scope Feature Examples

The scope feature in Pluraal provides a powerful way to define typed inputs and named calculations. This document provides comprehensive examples of how to use scopes.

## Basic Scope Structure

A scope consists of three main parts:

1. **Inputs**: Typed variables that must be provided
2. **Calculations**: Calculated values derived from inputs and other calculations  
3. **Result**: The final expression to evaluate

## Example 1: Simple Calculator

```elm
-- Define inputs with types
inputs = 
    [ { name = "x", type_ = NumberType }
    , { name = "y", type_ = NumberType }
    ]

-- Define calculations (simplified static examples)
calculations = Dict.fromList
  [ ( "sum", LiteralExpr (NumberLiteral 0) )
  , ( "product", LiteralExpr (NumberLiteral 0) )
  ]

-- Define the result
result = Reference "sum"

-- Create the scope
calculatorScope = { inputs = inputs, calculations = calculations, result = result }
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

-- Define calculations
calculations = Dict.fromList
  [ ( "fullName", Reference "firstName" ) -- In practice, would concatenate
    , ( "category"
      , BranchExpr (FiniteBranchBranch
            { branchOn = Reference "isActive"
            , cases = 
                [ ( LiteralExpr (BoolLiteral True), LiteralExpr (StringLiteral "active-user") )
                , ( LiteralExpr (BoolLiteral False), LiteralExpr (StringLiteral "inactive-user") )
                ]
            , otherwise = Just (LiteralExpr (StringLiteral "unknown"))
            })
      )
    ]

-- Define the result - return the category
result = Reference "category"

-- Create the scope
userScope = { inputs = inputs, calculations = calculations, result = result }
```

## Example 3: Chained Calculations

Calculations can reference other calculations, allowing for complex logic:

```elm
inputs = 
    [ { name = "baseValue", type_ = NumberType }
    ]

calculations = Dict.fromList
  [ ( "doubled", Reference "baseValue" )
  , ( "quadrupled", Reference "doubled" )  
  , ( "final", Reference "quadrupled" )
  ]

result = Reference "final"

chainedScope = { inputs = inputs, calculations = calculations, result = result }
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
  "calculations": {
    "fullName": "firstName",
    "category": {
      "branchOn": "isActive",
      "when": {
        "true": "active-user",
        "false": "inactive-user"
      },
      "otherwise": "unknown"
    }
  },
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
3. **Calculation Error**: "Error calculating calculation calculationName: ..."

## Best Practices

1. **Keep inputs minimal**: Only define inputs that are actually needed
2. **Use descriptive names**: Choose clear names for inputs and calculations
3. **Chain calculations logically**: Build complex calculations step by step
4. **Handle edge cases**: Use conditional logic to handle unexpected values
5. **Validate early**: Put type-sensitive operations in data points rather than the result
