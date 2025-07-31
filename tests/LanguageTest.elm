module LanguageTest exposing (..)

import Dict
import Expect
import Pluraal.Language exposing (..)
import Test exposing (..)


suite : Test
suite =
    describe "Pluraal Language"
        [ describe "Literals"
            [ test "String literal evaluation" <|
                \_ ->
                    let
                        expr = LiteralExpr (StringLiteral "hello")
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Ok expr)
            , test "Number literal evaluation" <|
                \_ ->
                    let
                        expr = LiteralExpr (NumberLiteral 42)
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Ok expr)
            , test "Boolean literal evaluation" <|
                \_ ->
                    let
                        expr = LiteralExpr (BoolLiteral True)
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Ok expr)
            ]
        , describe "Variables"
            [ test "Variable resolution" <|
                \_ ->
                    let
                        expr = VariableExpr "x"
                        value = LiteralExpr (StringLiteral "world")
                        context = Dict.singleton "x" value
                    in
                    evaluate context expr
                        |> Expect.equal (Ok value)
            , test "Undefined variable error" <|
                \_ ->
                    let
                        expr = VariableExpr "undefined"
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Err "Variable not found: undefined")
            ]
        , describe "If-then-else"
            [ test "True condition" <|
                \_ ->
                    let
                        condition = LiteralExpr (BoolLiteral True)
                        thenExpr = LiteralExpr (StringLiteral "then branch")
                        elseExpr = LiteralExpr (StringLiteral "else branch")
                        ifThenElse = { condition = condition, then_ = thenExpr, else_ = elseExpr }
                        expr = BranchExpr (IfThenElseBranch ifThenElse)
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Ok thenExpr)
            , test "False condition" <|
                \_ ->
                    let
                        condition = LiteralExpr (BoolLiteral False)
                        thenExpr = LiteralExpr (StringLiteral "then branch")
                        elseExpr = LiteralExpr (StringLiteral "else branch")
                        ifThenElse = { condition = condition, then_ = thenExpr, else_ = elseExpr }
                        expr = BranchExpr (IfThenElseBranch ifThenElse)
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Ok elseExpr)
            ]
        , describe "Rule chains"
            [ test "First rule matches" <|
                \_ ->
                    let
                        rule1 = { when = LiteralExpr (BoolLiteral True), then_ = LiteralExpr (StringLiteral "rule 1") }
                        rule2 = { when = LiteralExpr (BoolLiteral True), then_ = LiteralExpr (StringLiteral "rule 2") }
                        ruleChain = { rules = [ rule1, rule2 ], otherwise = Nothing }
                        expr = BranchExpr (RuleChainBranch ruleChain)
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Ok (LiteralExpr (StringLiteral "rule 1")))
            , test "Second rule matches" <|
                \_ ->
                    let
                        rule1 = { when = LiteralExpr (BoolLiteral False), then_ = LiteralExpr (StringLiteral "rule 1") }
                        rule2 = { when = LiteralExpr (BoolLiteral True), then_ = LiteralExpr (StringLiteral "rule 2") }
                        ruleChain = { rules = [ rule1, rule2 ], otherwise = Nothing }
                        expr = BranchExpr (RuleChainBranch ruleChain)
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Ok (LiteralExpr (StringLiteral "rule 2")))
            , test "No rule matches, use otherwise" <|
                \_ ->
                    let
                        rule1 = { when = LiteralExpr (BoolLiteral False), then_ = LiteralExpr (StringLiteral "rule 1") }
                        otherwiseExpr = LiteralExpr (StringLiteral "default")
                        ruleChain = { rules = [ rule1 ], otherwise = Just otherwiseExpr }
                        expr = BranchExpr (RuleChainBranch ruleChain)
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Ok otherwiseExpr)
            ]
        , describe "Finite branches"
            [ test "Matching case" <|
                \_ ->
                    let
                        branchOn = LiteralExpr (StringLiteral "A")
                        cases = Dict.fromList [ ( "A", LiteralExpr (StringLiteral "Case A") ), ( "B", LiteralExpr (StringLiteral "Case B") ) ]
                        finiteBranch = { branchOn = branchOn, cases = cases, otherwise = Nothing }
                        expr = BranchExpr (FiniteBranchBranch finiteBranch)
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Ok (LiteralExpr (StringLiteral "Case A")))
            , test "No matching case, use otherwise" <|
                \_ ->
                    let
                        branchOn = LiteralExpr (StringLiteral "C")
                        cases = Dict.fromList [ ( "A", LiteralExpr (StringLiteral "Case A") ), ( "B", LiteralExpr (StringLiteral "Case B") ) ]
                        otherwiseExpr = LiteralExpr (StringLiteral "Default case")
                        finiteBranch = { branchOn = branchOn, cases = cases, otherwise = Just otherwiseExpr }
                        expr = BranchExpr (FiniteBranchBranch finiteBranch)
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Ok otherwiseExpr)
            ]
        , describe "Scopes"
            [ test "Simple scope with typed inputs and data points" <|
                \_ ->
                    let
                        inputs = 
                            [ { name = "x", type_ = NumberType }
                            , { name = "y", type_ = NumberType }
                            ]
                        dataPoints =
                            [ { name = "sum", expression = BranchExpr (IfThenElseBranch { condition = LiteralExpr (BoolLiteral True), then_ = LiteralExpr (NumberLiteral 10), else_ = LiteralExpr (NumberLiteral 0) }) }
                            ]
                        result = VariableExpr "sum"
                        scope = { inputs = inputs, dataPoints = dataPoints, result = result }
                        expr = ScopeExpr scope
                        context = Dict.fromList 
                            [ ( "x", LiteralExpr (NumberLiteral 5) )
                            , ( "y", LiteralExpr (NumberLiteral 3) )
                            ]
                    in
                    evaluate context expr
                        |> Expect.equal (Ok (LiteralExpr (NumberLiteral 10)))
            , test "Scope with data point referencing input" <|
                \_ ->
                    let
                        inputs = 
                            [ { name = "name", type_ = StringType }
                            ]
                        dataPoints =
                            [ { name = "greeting", expression = VariableExpr "name" }
                            ]
                        result = VariableExpr "greeting"
                        scope = { inputs = inputs, dataPoints = dataPoints, result = result }
                        expr = ScopeExpr scope
                        context = Dict.singleton "name" (LiteralExpr (StringLiteral "Alice"))
                    in
                    evaluate context expr
                        |> Expect.equal (Ok (LiteralExpr (StringLiteral "Alice")))
            , test "Scope with missing input fails" <|
                \_ ->
                    let
                        inputs = 
                            [ { name = "x", type_ = NumberType }
                            ]
                        dataPoints = []
                        result = VariableExpr "x"
                        scope = { inputs = inputs, dataPoints = dataPoints, result = result }
                        expr = ScopeExpr scope
                        context = Dict.empty
                    in
                    evaluate context expr
                        |> Expect.equal (Err "Required input not found: x")
            , test "Scope with wrong input type fails" <|
                \_ ->
                    let
                        inputs = 
                            [ { name = "x", type_ = NumberType }
                            ]
                        dataPoints = []
                        result = VariableExpr "x"
                        scope = { inputs = inputs, dataPoints = dataPoints, result = result }
                        expr = ScopeExpr scope
                        context = Dict.singleton "x" (LiteralExpr (StringLiteral "not a number"))
                    in
                    evaluate context expr
                        |> Expect.equal (Err "Input x has incorrect type")
            , test "Scope with chained data points" <|
                \_ ->
                    let
                        inputs = 
                            [ { name = "base", type_ = NumberType }
                            ]
                        dataPoints =
                            [ { name = "doubled", expression = VariableExpr "base" }
                            , { name = "final", expression = VariableExpr "doubled" }
                            ]
                        result = VariableExpr "final"
                        scope = { inputs = inputs, dataPoints = dataPoints, result = result }
                        expr = ScopeExpr scope
                        context = Dict.singleton "base" (LiteralExpr (NumberLiteral 7))
                    in
                    evaluate context expr
                        |> Expect.equal (Ok (LiteralExpr (NumberLiteral 7)))
            ]
        ]
