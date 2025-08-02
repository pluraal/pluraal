module CodecTest exposing (..)

import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as JD
import Pluraal.Language exposing (Expression(..), Literal(..), Scope, Input, DataPoint, Type(..))
import Pluraal.Language.Codec as Codec
import Test exposing (..)


-- Fuzz generators for testing
literalFuzzer : Fuzzer Literal
literalFuzzer =
    Fuzz.oneOf
        [ Fuzz.map StringLiteral Fuzz.string
        , Fuzz.map NumberLiteral (Fuzz.floatRange -1000000 1000000)
        , Fuzz.map BoolLiteral Fuzz.bool
        , Fuzz.constant NullLiteral
        ]


expressionFuzzer : Fuzzer Expression
expressionFuzzer =
    Fuzz.oneOf
        [ Fuzz.map LiteralExpr literalFuzzer
        , Fuzz.map VariableExpr Fuzz.string
        ]


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


dataPointFuzzer : Fuzzer DataPoint
dataPointFuzzer =
    Fuzz.map2 DataPoint
        Fuzz.string
        expressionFuzzer


scopeFuzzer : Fuzzer Scope
scopeFuzzer =
    Fuzz.map3 Scope
        (Fuzz.list inputFuzzer)
        (Fuzz.list dataPointFuzzer)
        expressionFuzzer


-- Test round-trip encoding/decoding
codecRoundTripTest : Test
codecRoundTripTest =
    fuzz scopeFuzzer "encode then decode should return the same scope" <|
        \scope ->
            let
                encoded = Codec.encodeScope scope
                decoded = JD.decodeValue Codec.decodeScope encoded
            in
            case decoded of
                Ok decodedScope ->
                    Expect.equal scope decodedScope
                
                Err error ->
                    Expect.fail ("Decode failed: " ++ JD.errorToString error)


-- Main test suite
suite : Test
suite =
    describe "Codec Tests"
        [ codecRoundTripTest
        ]
