module Pluraal.Language exposing
    ( Expression(..), Literal(..), Branch(..), Rule, IfThenElse, RuleChain, FiniteBranch, Scope, Input, Type(..)
    , evaluate, evaluateRule, evaluateRuleChain, evaluateFiniteBranch, evaluateScope, calculateDataPoints
    , extractOutputs
    )

{-| The Pluraal Language implementation in Elm.

This module provides types and functions for working with the Pluraal declarative language
for defining rules and logic. Scope is now a separate top-level construct, not an expression type.


# Core Types

@docs Expression, Literal, Branch, Rule, IfThenElse, RuleChain, FiniteBranch, Scope, Input, Type


# Evaluation

@docs evaluate, evaluateRule, evaluateRuleChain, evaluateFiniteBranch, evaluateScope, calculateDataPoints

-}

import Dict exposing (Dict)
import Set exposing (Set)



-- TYPES


{-| Core expression type representing all possible Pluraal values
-}
type Expression
    = LiteralExpr Literal
    | Reference String
    | BranchExpr Branch


{-| Literal values in the Pluraal language
-}
type Literal
    = StringLiteral String
    | NumberLiteral Float
    | BoolLiteral Bool


{-| Branching constructs for conditional logic
-}
type Branch
    = IfThenElseBranch IfThenElse
    | RuleChainBranch RuleChain
    | FiniteBranchBranch FiniteBranch


{-| Simple if-then-else conditional
-}
type alias IfThenElse =
    { condition : Expression
    , then_ : Expression
    , else_ : Expression
    }


{-| Rule with a condition and result
-}
type alias Rule =
    { when : Expression
    , then_ : Expression
    }


{-| Chain of rules with an optional fallback
-}
type alias RuleChain =
    { rules : List Rule
    , otherwise : Maybe Expression
    }


{-| Finite branching based on expression value
-}
type alias FiniteBranch =
    { branchOn : Expression
    , cases : List ( Expression, Expression )
    , otherwise : Maybe Expression
    }


{-| Type system for scope inputs
-}
type Type
    = StringType
    | NumberType
    | BoolType


{-| Input definition with name and type
-}
type alias Input =
    { name : String
    , type_ : Type
    }


{-| Scope with typed inputs and calculated data points
-}
type alias Scope =
    { inputs : List Input
    , calculations : Dict String Expression
    , outputs : Set String
    }



-- EVALUATION


{-| Evaluate an expression with a given context
-}
evaluate : Dict String Expression -> Expression -> Result String Expression
evaluate context expr =
    case expr of
        LiteralExpr literal ->
            Ok (LiteralExpr literal)

        Reference name ->
            case Dict.get name context of
                Just value ->
                    evaluate context value

                Nothing ->
                    Err ("Variable not found: " ++ name)

        BranchExpr branch ->
            evaluateBranch context branch


{-| Evaluate a branching construct
-}
evaluateBranch : Dict String Expression -> Branch -> Result String Expression
evaluateBranch context branch =
    case branch of
        IfThenElseBranch ifThenElse ->
            evaluateIfThenElse context ifThenElse

        RuleChainBranch ruleChain ->
            evaluateRuleChain context ruleChain

        FiniteBranchBranch finiteBranch ->
            evaluateFiniteBranch context finiteBranch


{-| Evaluate an if-then-else expression
-}
evaluateIfThenElse : Dict String Expression -> IfThenElse -> Result String Expression
evaluateIfThenElse context { condition, then_, else_ } =
    case evaluate context condition of
        Ok (LiteralExpr (BoolLiteral True)) ->
            evaluate context then_

        Ok (LiteralExpr (BoolLiteral False)) ->
            evaluate context else_

        Ok _ ->
            Err "Condition must evaluate to a boolean"

        Err err ->
            Err err


{-| Evaluate a rule (helper function)
-}
evaluateRule : Dict String Expression -> Rule -> Result String (Maybe Expression)
evaluateRule context { when, then_ } =
    case evaluate context when of
        Ok (LiteralExpr (BoolLiteral True)) ->
            evaluate context then_
                |> Result.map Just

        Ok (LiteralExpr (BoolLiteral False)) ->
            Ok Nothing

        Ok _ ->
            Err "Rule condition must evaluate to a boolean"

        Err err ->
            Err err


{-| Evaluate a chain of rules
-}
evaluateRuleChain : Dict String Expression -> RuleChain -> Result String Expression
evaluateRuleChain context { rules, otherwise } =
    evaluateRulesHelper context rules otherwise


{-| Helper function to evaluate rules in sequence
-}
evaluateRulesHelper : Dict String Expression -> List Rule -> Maybe Expression -> Result String Expression
evaluateRulesHelper context rules otherwise =
    case rules of
        [] ->
            case otherwise of
                Just defaultExpr ->
                    evaluate context defaultExpr

                Nothing ->
                    Err "No rule matched and no otherwise clause provided"

        rule :: remainingRules ->
            case evaluateRule context rule of
                Ok (Just result) ->
                    Ok result

                Ok Nothing ->
                    evaluateRulesHelper context remainingRules otherwise

                Err err ->
                    Err err


{-| Evaluate a finite branch expression
-}
evaluateFiniteBranch : Dict String Expression -> FiniteBranch -> Result String Expression
evaluateFiniteBranch context { branchOn, cases, otherwise } =
    case evaluate context branchOn of
        Ok switchValue ->
            -- Find matching case by evaluating each case key
            case findMatchingCase context switchValue cases of
                Just expr ->
                    evaluate context expr

                Nothing ->
                    case otherwise of
                        Just defaultExpr ->
                            evaluate context defaultExpr

                        Nothing ->
                            Err ("No case found for value: " ++ expressionToString switchValue)

        Err err ->
            Err err


{-| Helper function to find a matching case by comparing evaluated expressions
-}
findMatchingCase : Dict String Expression -> Expression -> List ( Expression, Expression ) -> Maybe Expression
findMatchingCase context switchValue cases =
    case cases of
        [] ->
            Nothing

        ( caseKey, caseExpr ) :: remainingCases ->
            case evaluate context caseKey of
                Ok evaluatedKey ->
                    if expressionsEqual switchValue evaluatedKey then
                        Just caseExpr

                    else
                        findMatchingCase context switchValue remainingCases

                Err _ ->
                    findMatchingCase context switchValue remainingCases


{-| Check if two expressions are equal (for case matching)
-}
expressionsEqual : Expression -> Expression -> Bool
expressionsEqual expr1 expr2 =
    case ( expr1, expr2 ) of
        ( LiteralExpr lit1, LiteralExpr lit2 ) ->
            literalsEqual lit1 lit2

        ( Reference name1, Reference name2 ) ->
            name1 == name2

        _ ->
            False


{-| Check if two literals are equal
-}
literalsEqual : Literal -> Literal -> Bool
literalsEqual lit1 lit2 =
    case ( lit1, lit2 ) of
        ( StringLiteral str1, StringLiteral str2 ) ->
            str1 == str2

        ( NumberLiteral num1, NumberLiteral num2 ) ->
            num1 == num2

        ( BoolLiteral bool1, BoolLiteral bool2 ) ->
            bool1 == bool2

        _ ->
            False


{-| Convert expression to string for error messages
-}
expressionToString : Expression -> String
expressionToString expr =
    case expr of
        LiteralExpr literal ->
            literalToString literal

        Reference name ->
            name

        BranchExpr _ ->
            "branch"


{-| Convert literal to string
-}
literalToString : Literal -> String
literalToString literal =
    case literal of
        StringLiteral str ->
            "\"" ++ str ++ "\""

        NumberLiteral num ->
            String.fromFloat num

        BoolLiteral bool ->
            if bool then
                "true"

            else
                "false"


{-| Validate that a literal value matches the expected type
-}
validateType : Type -> Literal -> Bool
validateType expectedType literal =
    case ( expectedType, literal ) of
        ( StringType, StringLiteral _ ) ->
            True

        ( NumberType, NumberLiteral _ ) ->
            True

        ( BoolType, BoolLiteral _ ) ->
            True

        _ ->
            False


{-| Evaluate a scope with type checking and data point calculation
-}
evaluateScope : Dict String Expression -> Scope -> Result String (Dict String Expression)
evaluateScope context { inputs, calculations, outputs } =
    -- First, validate that all required inputs are present and have correct types
    case validateInputs context inputs of
        Err err ->
            Err err

        Ok () ->
            -- Calculate data points in order, building up the context
            case calculateDataPoints context calculations of
                Err err ->
                    Err err

                Ok extendedContext ->
                    -- Extract only the requested outputs
                    Ok (extractOutputs extendedContext outputs)


{-| Extract only the specified outputs from the extended context
-}
extractOutputs : Dict String Expression -> Set String -> Dict String Expression
extractOutputs context outputNames =
    Set.foldl
        (\name acc ->
            case Dict.get name context of
                Just value ->
                    Dict.insert name value acc

                Nothing ->
                    acc
         -- Skip missing outputs (could log warning)
        )
        Dict.empty
        outputNames


{-| Validate that all inputs are present in context and have correct types
-}
validateInputs : Dict String Expression -> List Input -> Result String ()
validateInputs context inputs =
    validateInputsHelper context inputs


{-| Helper function to validate inputs recursively
-}
validateInputsHelper : Dict String Expression -> List Input -> Result String ()
validateInputsHelper context inputs =
    case inputs of
        [] ->
            Ok ()

        input :: remainingInputs ->
            case Dict.get input.name context of
                Nothing ->
                    Err ("Required input not found: " ++ input.name)

                Just expr ->
                    case evaluate context expr of
                        Ok (LiteralExpr literal) ->
                            if validateType input.type_ literal then
                                validateInputsHelper context remainingInputs

                            else
                                Err ("Input " ++ input.name ++ " has incorrect type")

                        Ok _ ->
                            Err ("Input " ++ input.name ++ " must be a literal value")

                        Err err ->
                            Err err


{-| Calculate all data points and extend the context
-}
calculateDataPoints : Dict String Expression -> Dict String Expression -> Result String (Dict String Expression)
calculateDataPoints context dataPoints =
    calculateDataPointsHelper context context dataPoints (Dict.keys dataPoints)


{-| Helper function to calculate data points recursively
Note: This processes data points in arbitrary order since Dict doesn't preserve order.
For dependency-aware processing, we'd need topological sorting.
-}
calculateDataPointsHelper : Dict String Expression -> Dict String Expression -> Dict String Expression -> List String -> Result String (Dict String Expression)
calculateDataPointsHelper originalContext currentContext dataPoints remainingNames =
    case remainingNames of
        [] ->
            Ok currentContext

        name :: otherNames ->
            case Dict.get name dataPoints of
                Just expression ->
                    case evaluate currentContext expression of
                        Ok value ->
                            let
                                extendedContext =
                                    Dict.insert name value currentContext
                            in
                            calculateDataPointsHelper originalContext extendedContext dataPoints otherNames

                        Err err ->
                            Err ("Error calculating calculation " ++ name ++ ": " ++ err)

                Nothing ->
                    -- This shouldn't happen if remainingNames comes from Dict.keys dataPoints
                    calculateDataPointsHelper originalContext currentContext dataPoints otherNames
