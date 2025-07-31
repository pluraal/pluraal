module ScopeDemo exposing (..)

{-| Demonstration of the new Scope feature in Pluraal Language

This module shows practical examples of using scopes with typed inputs and calculated data points.
-}

import Dict exposing (Dict)
import Pluraal.Language exposing (..)


{-| Example 1: Simple calculator scope
-}
calculatorScope : Scope
calculatorScope =
    { inputs =
        [ { name = "x", type_ = NumberType }
        , { name = "y", type_ = NumberType }
        ]
    , dataPoints =
        [ { name = "sum", expression = 
            BranchExpr (IfThenElseBranch 
                { condition = LiteralExpr (BoolLiteral True)
                , then_ = LiteralExpr (NumberLiteral 15) -- In practice would calculate x + y
                , else_ = LiteralExpr (NumberLiteral 0)
                })
          }
        , { name = "product", expression = 
            BranchExpr (IfThenElseBranch 
                { condition = LiteralExpr (BoolLiteral True)
                , then_ = LiteralExpr (NumberLiteral 50) -- In practice would calculate x * y
                , else_ = LiteralExpr (NumberLiteral 0)
                })
          }
        ]
    , result = VariableExpr "sum"
    }


{-| Context for calculator demo
-}
calculatorContext : Dict String Expression
calculatorContext =
    Dict.fromList
        [ ( "x", LiteralExpr (NumberLiteral 10) )
        , ( "y", LiteralExpr (NumberLiteral 5) )
        ]


{-| Example 2: User processing scope with type validation
-}
userProcessingScope : Scope
userProcessingScope =
    { inputs =
        [ { name = "firstName", type_ = StringType }
        , { name = "lastName", type_ = StringType }
        , { name = "age", type_ = NumberType }
        , { name = "isActive", type_ = BoolType }
        ]
    , dataPoints =
        [ { name = "fullName", expression = VariableExpr "firstName" } -- Simplified
        , { name = "status", expression = 
            BranchExpr (IfThenElseBranch 
                { condition = VariableExpr "isActive"
                , then_ = LiteralExpr (StringLiteral "active")
                , else_ = LiteralExpr (StringLiteral "inactive")
                })
          }
        ]
    , result = VariableExpr "status"
    }


{-| Context for user processing demo
-}
userContext : Dict String Expression
userContext =
    Dict.fromList
        [ ( "firstName", LiteralExpr (StringLiteral "Alice") )
        , ( "lastName", LiteralExpr (StringLiteral "Johnson") )
        , ( "age", LiteralExpr (NumberLiteral 30) )
        , ( "isActive", LiteralExpr (BoolLiteral True) )
        ]


{-| Example 3: Chained data points scope
-}
chainedScope : Scope
chainedScope =
    { inputs =
        [ { name = "base", type_ = NumberType }
        ]
    , dataPoints =
        [ { name = "doubled", expression = VariableExpr "base" }
        , { name = "quadrupled", expression = VariableExpr "doubled" }
        , { name = "final", expression = VariableExpr "quadrupled" }
        ]
    , result = VariableExpr "final"
    }


{-| Context for chained demo
-}
chainedContext : Dict String Expression
chainedContext =
    Dict.singleton "base" (LiteralExpr (NumberLiteral 7))


{-| Run all demos and show results
-}
runDemos : List (String, Result String Expression)
runDemos =
    [ ( "Calculator", evaluate calculatorContext (ScopeExpr calculatorScope) )
    , ( "User Processing", evaluate userContext (ScopeExpr userProcessingScope) )
    , ( "Chained Data Points", evaluate chainedContext (ScopeExpr chainedScope) )
    ]


{-| Demo of error handling - missing input
-}
errorDemo1 : Result String Expression
errorDemo1 =
    let
        incompleteContext = Dict.singleton "x" (LiteralExpr (NumberLiteral 5))
    in
    evaluate incompleteContext (ScopeExpr calculatorScope)


{-| Demo of error handling - wrong type
-}
errorDemo2 : Result String Expression
errorDemo2 =
    let
        wrongTypeContext = Dict.fromList
            [ ( "x", LiteralExpr (StringLiteral "not a number") )
            , ( "y", LiteralExpr (NumberLiteral 5) )
            ]
    in
    evaluate wrongTypeContext (ScopeExpr calculatorScope)
