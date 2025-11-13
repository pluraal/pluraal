module CodecTest exposing (..)

import Dict
import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as JD
import Pluraal.Language exposing (Branch(..), Expression(..), Input, Literal(..), Scope, Type(..))
import Pluraal.Language.Codec as Codec
import Set
import Test exposing (..)



-- Fuzz generators for testing


literalFuzzer : Fuzzer Literal
literalFuzzer =
    Fuzz.oneOf
        [ Fuzz.map StringLiteral Fuzz.string
        , Fuzz.map NumberLiteral (Fuzz.floatRange -1000000 1000000)
        , Fuzz.map BoolLiteral Fuzz.bool
        ]


{-| Depth-limited recursive expression fuzzer to include branch expressions safely.
We cap depth to avoid infinite structures. At depth 0 we only create simple expressions.
-}
expressionFuzzer : Fuzzer Expression
expressionFuzzer =
    expressionFuzzerHelp 3


expressionFuzzerHelp : Int -> Fuzzer Expression
expressionFuzzerHelp depth =
    if depth <= 0 then
        Fuzz.oneOf
            [ Fuzz.map LiteralExpr literalFuzzer
            , Fuzz.map Reference Fuzz.string
            ]

    else
        Fuzz.frequency
            [ ( 4
              , Fuzz.oneOf
                    [ Fuzz.map LiteralExpr literalFuzzer
                    , Fuzz.map Reference Fuzz.string
                    ]
              )
            , ( 1, Fuzz.map BranchExpr (branchFuzzerHelp (depth - 1)) )
            ]


branchFuzzer : Fuzzer Branch
branchFuzzer =
    branchFuzzerHelp 2


branchFuzzerHelp : Int -> Fuzzer Branch
branchFuzzerHelp depth =
    if depth <= 0 then
        -- Base: no nested branches, only literals / refs inside
        let
            simpleExpr =
                expressionFuzzerHelp 0
        in
        Fuzz.oneOf
            [ Fuzz.map3 (\c t e -> IfThenElseBranch { condition = c, then_ = t, else_ = e }) simpleExpr simpleExpr simpleExpr
            , ruleChainFuzzer 0
            , finiteBranchFuzzer 0
            ]

    else
        Fuzz.oneOf
            [ Fuzz.map3 (\c t e -> IfThenElseBranch { condition = c, then_ = t, else_ = e }) (expressionFuzzerHelp (depth - 1)) (expressionFuzzerHelp (depth - 1)) (expressionFuzzerHelp (depth - 1))
            , ruleChainFuzzer (depth - 1)
            , finiteBranchFuzzer (depth - 1)
            ]


ruleChainFuzzer : Int -> Fuzzer Branch
ruleChainFuzzer depth =
    let
        expr =
            expressionFuzzerHelp depth

        ruleFuzzer =
            Fuzz.map2 (\w t -> { when = w, then_ = t }) expr expr
    in
    Fuzz.map2
        (\rules otherwise -> RuleChainBranch { rules = rules, otherwise = otherwise })
        (Fuzz.listOfLengthBetween 0 3 ruleFuzzer)
        (Fuzz.maybe expr)


finiteBranchFuzzer : Int -> Fuzzer Branch
finiteBranchFuzzer depth =
    let
        expr =
            expressionFuzzerHelp depth

        caseFuzzer =
            Fuzz.map2 Tuple.pair expr expr
    in
    Fuzz.map3
        (\branchOn cases otherwise -> FiniteBranchBranch { branchOn = branchOn, cases = cases, otherwise = otherwise })
        expr
        (Fuzz.listOfLengthBetween 0 3 caseFuzzer)
        (Fuzz.maybe expr)


typeFuzzer : Fuzzer Type
typeFuzzer =
    Fuzz.oneOf
        [ Fuzz.constant StringType
        , Fuzz.constant NumberType
        , Fuzz.constant BoolType
        ]


inputFuzzer : Fuzzer Input
inputFuzzer =
    Fuzz.map2 Input
        Fuzz.string
        typeFuzzer


calculationsFuzzer : Fuzzer (Dict.Dict String Expression)
calculationsFuzzer =
    Fuzz.list (Fuzz.map2 (\name expr -> ( name, expr )) Fuzz.string expressionFuzzer)
        |> Fuzz.map Dict.fromList


outputsFuzzer : Fuzzer (Set.Set String)
outputsFuzzer =
    Fuzz.list Fuzz.string
        |> Fuzz.map Set.fromList


scopeFuzzer : Fuzzer Scope
scopeFuzzer =
    Fuzz.map3 Scope
        (Fuzz.list inputFuzzer)
        calculationsFuzzer
        outputsFuzzer



-- Test round-trip encoding/decoding


codecRoundTripTest : Test
codecRoundTripTest =
    fuzz scopeFuzzer "encode then decode should return the same scope" <|
        \scope ->
            let
                encoded =
                    Codec.encodeScope scope

                decoded =
                    JD.decodeValue Codec.decodeScope encoded

                normalizeInputs inputs =
                    inputs
                        |> List.map (\i -> ( i.name, i.type_ ))
                        |> Dict.fromList
                        |> Dict.toList
                        |> List.map (\( name, type_ ) -> { name = name, type_ = type_ })

                normalizeScope s =
                    { s | inputs = normalizeInputs s.inputs }
            in
            case decoded of
                Ok decodedScope ->
                    Expect.equal (normalizeScope scope) (normalizeScope decodedScope)

                Err error ->
                    Expect.fail ("Decode failed: " ++ JD.errorToString error)



-- Main test suite


suite : Test
suite =
    describe "Codec Tests"
        [ codecRoundTripTest
        ]
