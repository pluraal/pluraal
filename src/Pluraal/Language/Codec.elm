module Pluraal.Language.Codec exposing
    ( encodeExpression
    , decodeExpression
    , encodeLiteral
    , decodeLiteral
    , encodeBranch
    , decodeBranch
    , encodeRule
    , decodeRule
    , encodeScope
    , decodeScope
    , encodeType
    , decodeType
    , encodeInput
    , decodeInput
    , encodeDataPoint
    , decodeDataPoint
    )

{-| JSON encoding and decoding for the Pluraal Language.

This module provides functions for serializing and deserializing Pluraal language
constructs to and from JSON format.

# Expression Encoding/Decoding
@docs encodeExpression, decodeExpression

# Literal Encoding/Decoding
@docs encodeLiteral, decodeLiteral

# Branch Encoding/Decoding
@docs encodeBranch, decodeBranch

# Rule Encoding/Decoding
@docs encodeRule, decodeRule

# Scope Encoding/Decoding
@docs encodeScope, decodeScope

# Type System Encoding/Decoding
@docs encodeType, decodeType

# Input Encoding/Decoding
@docs encodeInput, decodeInput

# DataPoint Encoding/Decoding
@docs encodeDataPoint, decodeDataPoint

-}

import Dict
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Pluraal.Language exposing (..)


-- ENCODING


{-| Encode an expression to JSON
-}
encodeExpression : Expression -> Value
encodeExpression expr =
    case expr of
        LiteralExpr literal ->
            encodeLiteral literal

        VariableExpr name ->
            Encode.string name

        BranchExpr branch ->
            encodeBranch branch

        ScopeExpr scope ->
            encodeScope scope


{-| Encode a literal to JSON
-}
encodeLiteral : Literal -> Value
encodeLiteral literal =
    case literal of
        StringLiteral str ->
            Encode.string str

        NumberLiteral num ->
            Encode.float num

        BoolLiteral bool ->
            Encode.bool bool

        NullLiteral ->
            Encode.null


{-| Encode a branch to JSON
-}
encodeBranch : Branch -> Value
encodeBranch branch =
    case branch of
        IfThenElseBranch { condition, then_, else_ } ->
            Encode.object
                [ ( "if", encodeExpression condition )
                , ( "then", encodeExpression then_ )
                , ( "else", encodeExpression else_ )
                ]

        RuleChainBranch { rules, otherwise } ->
            let
                encodedRules =
                    List.map encodeRule rules

                baseObject =
                    [ ( "rules", Encode.list identity encodedRules ) ]

                objectWithOtherwise =
                    case otherwise of
                        Just expr ->
                            ( "otherwise", encodeExpression expr ) :: baseObject

                        Nothing ->
                            baseObject
            in
            Encode.object objectWithOtherwise

        FiniteBranchBranch { branchOn, cases, otherwise } ->
            let
                encodedCases =
                    Dict.toList cases
                        |> List.map (\( k, v ) -> ( k, encodeExpression v ))
                        |> Encode.object

                baseObject =
                    [ ( "branchOn", encodeExpression branchOn )
                    , ( "when", encodedCases )
                    ]

                objectWithOtherwise =
                    case otherwise of
                        Just expr ->
                            ( "otherwise", encodeExpression expr ) :: baseObject

                        Nothing ->
                            baseObject
            in
            Encode.object objectWithOtherwise


{-| Encode a rule to JSON
-}
encodeRule : Rule -> Value
encodeRule { when, then_ } =
    Encode.object
        [ ( "when", encodeExpression when )
        , ( "then", encodeExpression then_ )
        ]


{-| Encode a scope to JSON
-}
encodeScope : Scope -> Value
encodeScope { inputs, dataPoints, result } =
    Encode.object
        [ ( "inputs", Encode.list encodeInput inputs )
        , ( "dataPoints", Encode.list encodeDataPoint dataPoints )
        , ( "result", encodeExpression result )
        ]


{-| Encode a type to JSON
-}
encodeType : Type -> Value
encodeType type_ =
    case type_ of
        StringType ->
            Encode.string "string"

        NumberType ->
            Encode.string "number"

        BoolType ->
            Encode.string "bool"


{-| Encode an input to JSON
-}
encodeInput : Input -> Value
encodeInput { name, type_ } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "type", encodeType type_ )
        ]


{-| Encode a data point to JSON
-}
encodeDataPoint : DataPoint -> Value
encodeDataPoint { name, expression } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "expression", encodeExpression expression )
        ]


-- DECODING


{-| Decode an expression from JSON
-}
decodeExpression : Decoder Expression
decodeExpression =
    Decode.oneOf
        [ Decode.map LiteralExpr decodeLiteral
        , Decode.map VariableExpr Decode.string
        , Decode.map BranchExpr (Decode.lazy (\_ -> decodeBranch))
        , Decode.map ScopeExpr (Decode.lazy (\_ -> decodeScope))
        ]


{-| Decode a literal from JSON
-}
decodeLiteral : Decoder Literal
decodeLiteral =
    Decode.oneOf
        [ Decode.map StringLiteral Decode.string
        , Decode.map NumberLiteral Decode.float
        , Decode.map BoolLiteral Decode.bool
        , Decode.null NullLiteral
        ]


{-| Decode a branch from JSON
-}
decodeBranch : Decoder Branch
decodeBranch =
    Decode.oneOf
        [ decodeIfThenElse
        , decodeRuleChain
        , decodeFiniteBranch
        ]


{-| Decode an if-then-else from JSON
-}
decodeIfThenElse : Decoder Branch
decodeIfThenElse =
    Decode.map3 (\c t e -> IfThenElseBranch { condition = c, then_ = t, else_ = e })
        (Decode.field "if" (Decode.lazy (\_ -> decodeExpression)))
        (Decode.field "then" (Decode.lazy (\_ -> decodeExpression)))
        (Decode.field "else" (Decode.lazy (\_ -> decodeExpression)))


{-| Decode a rule chain from JSON
-}
decodeRuleChain : Decoder Branch
decodeRuleChain =
    Decode.map2 (\rules otherwise -> RuleChainBranch { rules = rules, otherwise = otherwise })
        (Decode.field "rules" (Decode.list (Decode.lazy (\_ -> decodeRule))))
        (Decode.maybe (Decode.field "otherwise" (Decode.lazy (\_ -> decodeExpression))))


{-| Decode a rule from JSON
-}
decodeRule : Decoder Rule
decodeRule =
    Decode.map2 (\when then_ -> { when = when, then_ = then_ })
        (Decode.field "when" (Decode.lazy (\_ -> decodeExpression)))
        (Decode.field "then" (Decode.lazy (\_ -> decodeExpression)))


{-| Decode a finite branch from JSON
-}
decodeFiniteBranch : Decoder Branch
decodeFiniteBranch =
    Decode.map3 (\branchOn cases otherwise -> FiniteBranchBranch { branchOn = branchOn, cases = cases, otherwise = otherwise })
        (Decode.field "branchOn" (Decode.lazy (\_ -> decodeExpression)))
        (Decode.field "when" (Decode.dict (Decode.lazy (\_ -> decodeExpression))))
        (Decode.maybe (Decode.field "otherwise" (Decode.lazy (\_ -> decodeExpression))))


{-| Decode a scope from JSON
-}
decodeScope : Decoder Scope
decodeScope =
    Decode.map3 (\inputs dataPoints result -> { inputs = inputs, dataPoints = dataPoints, result = result })
        (Decode.field "inputs" (Decode.list (Decode.lazy (\_ -> decodeInput))))
        (Decode.field "dataPoints" (Decode.list (Decode.lazy (\_ -> decodeDataPoint))))
        (Decode.field "result" (Decode.lazy (\_ -> decodeExpression)))


{-| Decode a type from JSON
-}
decodeType : Decoder Type
decodeType =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "string" ->
                        Decode.succeed StringType

                    "number" ->
                        Decode.succeed NumberType

                    "bool" ->
                        Decode.succeed BoolType

                    _ ->
                        Decode.fail ("Unknown type: " ++ str)
            )


{-| Decode an input from JSON
-}
decodeInput : Decoder Input
decodeInput =
    Decode.map2 (\name type_ -> { name = name, type_ = type_ })
        (Decode.field "name" Decode.string)
        (Decode.field "type" (Decode.lazy (\_ -> decodeType)))


{-| Decode a data point from JSON
-}
decodeDataPoint : Decoder DataPoint
decodeDataPoint =
    Decode.map2 (\name expression -> { name = name, expression = expression })
        (Decode.field "name" Decode.string)
        (Decode.field "expression" (Decode.lazy (\_ -> decodeExpression)))
