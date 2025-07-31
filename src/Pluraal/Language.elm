module Pluraal.Language exposing
    ( Expression(..)
    , Literal(..)
    , Branch(..)
    , Rule
    , IfThenElse
    , RuleChain
    , FiniteBranch
    , evaluate
    , evaluateRule
    , evaluateRuleChain
    , evaluateFiniteBranch
    )

{-| The Pluraal Language implementation in Elm.

This module provides types and functions for working with the Pluraal declarative language
for defining rules and logic.

# Core Types
@docs Expression, Literal, Branch, Rule, IfThenElse, RuleChain, FiniteBranch

# Evaluation
@docs evaluate, evaluateRule, evaluateRuleChain, evaluateFiniteBranch

-}

import Dict exposing (Dict)


-- TYPES


{-| Core expression type representing all possible Pluraal values
-}
type Expression
    = LiteralExpr Literal
    | VariableExpr String
    | BranchExpr Branch


{-| Literal values in the Pluraal language
-}
type Literal
    = StringLiteral String
    | NumberLiteral Float
    | BoolLiteral Bool
    | NullLiteral


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
    , cases : Dict String Expression
    , otherwise : Maybe Expression
    }


-- EVALUATION


{-| Evaluate an expression with a given context
-}
evaluate : Dict String Expression -> Expression -> Result String Expression
evaluate context expr =
    case expr of
        LiteralExpr literal ->
            Ok (LiteralExpr literal)

        VariableExpr name ->
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
        Ok (LiteralExpr (StringLiteral key)) ->
            case Dict.get key cases of
                Just expr ->
                    evaluate context expr

                Nothing ->
                    case otherwise of
                        Just defaultExpr ->
                            evaluate context defaultExpr

                        Nothing ->
                            Err ("No case found for key: " ++ key)

        Ok _ ->
            Err "Branch expression must evaluate to a string"

        Err err ->
            Err err
