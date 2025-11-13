module Pluraal.Language.Codec exposing
    ( encodeExpression, decodeExpression
    , encodeLiteral, decodeLiteral
    , encodeBranch, decodeBranch
    , encodeRule, decodeRule
    , encodeScope, decodeScope
    , encodeType, decodeType
    , encodeInput, decodeInput
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

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Pluraal.Language exposing (..)
import Set exposing (Set)



-- ENCODING


{-| Encode an expression to JSON
-}
encodeExpression : Expression -> Value
encodeExpression expr =
    case expr of
        LiteralExpr literal ->
            encodeLiteral literal

        Reference name ->
            Encode.object [ ( "ref", Encode.string name ) ]

        BranchExpr branch ->
            Encode.object
                [ ( "type", Encode.string "branch" )
                , ( "value", encodeBranch branch )
                ]


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
                    cases
                        |> List.map (\( k, v ) -> Encode.list identity [ encodeExpression k, encodeExpression v ])
                        |> Encode.list identity

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
encodeScope { inputs, calculations, outputs } =
    Encode.object
        [ ( "inputs", encodeInputsObject inputs )
        , ( "calculations", encodeCalculationsObject calculations )
        , ( "outputs", Encode.list Encode.string (Set.toList outputs) )
        ]


{-| Encode inputs as an object keyed by name with type string values
-}
encodeInputsObject : List Input -> Value
encodeInputsObject inputs =
    inputs
        |> List.map (\inp -> ( inp.name, encodeType inp.type_ ))
        |> Encode.object


{-| Encode data points as an object keyed by name with expression values
-}
encodeCalculationsObject : Dict String Expression -> Value
encodeCalculationsObject dataPoints =
    dataPoints
        |> Dict.toList
        |> List.map (\( name, expression ) -> ( name, encodeExpression expression ))
        |> Encode.object


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



-- DECODING


{-| Decode an expression from JSON
-}
decodeExpression : Decoder Expression
decodeExpression =
    let
        refDecoder =
            Decode.field "ref" Decode.string |> Decode.map Reference

        branchDecoder =
            Decode.field "type" Decode.string
                |> Decode.andThen
                    (\typeStr ->
                        case typeStr of
                            "branch" ->
                                Decode.map BranchExpr (Decode.field "value" (Decode.lazy (\_ -> decodeBranch)))

                            _ ->
                                Decode.fail "Not a branch"
                    )

        -- New compact literal form: bare JSON primitive (string / number / bool)
        primitiveLiteralDecoder =
            Decode.map LiteralExpr decodeLiteral
    in
    Decode.oneOf [ primitiveLiteralDecoder, refDecoder, branchDecoder ]


{-| Decode a literal from JSON
-}
decodeLiteral : Decoder Literal
decodeLiteral =
    Decode.oneOf
        [ Decode.map StringLiteral Decode.string
        , Decode.map NumberLiteral Decode.float
        , Decode.map BoolLiteral Decode.bool
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
        (Decode.field "when" decodeExpressionPairs)
        (Decode.maybe (Decode.field "otherwise" (Decode.lazy (\_ -> decodeExpression))))


{-| Decode a list of (Expression, Expression) pairs from a list of [key, value] pairs
-}
decodeExpressionPairs : Decoder (List ( Expression, Expression ))
decodeExpressionPairs =
    Decode.list (Decode.list (Decode.lazy (\_ -> decodeExpression)))
        |> Decode.andThen
            (\pairs ->
                case convertPairsList pairs of
                    Ok pairsList ->
                        Decode.succeed pairsList

                    Err error ->
                        Decode.fail error
            )


{-| Convert list of [key, value] lists to list of (key, value) tuples
-}
convertPairsList : List (List Expression) -> Result String (List ( Expression, Expression ))
convertPairsList pairs =
    case pairs of
        [] ->
            Ok []

        [ key, value ] :: remainingPairs ->
            case convertPairsList remainingPairs of
                Ok remainingTuples ->
                    Ok (( key, value ) :: remainingTuples)

                Err error ->
                    Err error

        _ :: _ ->
            Err "Invalid case format: each case must be a [key, value] pair"


{-| Decode a scope from JSON
-}
decodeScope : Decoder Scope
decodeScope =
    Decode.map3 (\inputs calculations outputs -> { inputs = inputs, calculations = calculations, outputs = outputs })
        (Decode.field "inputs" decodeInputsObject)
        (Decode.field "calculations" decodeDataPointsObject)
        (Decode.field "outputs" (Decode.list Decode.string |> Decode.map Set.fromList))


{-| Decode inputs from an object keyed by name to type
-}
decodeInputsObject : Decoder (List Input)
decodeInputsObject =
    Decode.dict (Decode.lazy (\_ -> decodeType))
        |> Decode.map (\d -> d |> Dict.toList |> List.map (\( name, type_ ) -> { name = name, type_ = type_ }))


{-| Decode data points from an object keyed by name to expression
-}
decodeDataPointsObject : Decoder (Dict String Expression)
decodeDataPointsObject =
    Decode.dict (Decode.lazy (\_ -> decodeExpression))


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
