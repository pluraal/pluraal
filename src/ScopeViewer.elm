module ScopeViewer exposing (main)

{-| A UI application for displaying and interacting with Pluraal Scopes.

This module provides a visual interface for viewing scope definitions,
providing inputs, and seeing the evaluation results.

-}

import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Pluraal.Language exposing (..)
import Pluraal.Language.Codec exposing (decodeScope)
import Set exposing (Set)



-- MODEL


type alias Model =
    { scope : Maybe Scope
    , scopeLoadingState : LoadingState
    , inputValues : Dict String String
    , evaluationResult : Maybe (Result String (Dict String Expression))
    }


type LoadingState
    = Loading
    | LoadSuccess
    | LoadError String


init : () -> ( Model, Cmd Msg )
init _ =
    ( { scope = Nothing
      , scopeLoadingState = Loading
      , inputValues = Dict.empty
      , evaluationResult = Nothing
      }
    , loadScope
    )



-- UPDATE


type Msg
    = InputChanged String String
    | ScopeLoaded (Result Http.Error Scope)


{-| Load scope from JSON file
-}
loadScope : Cmd Msg
loadScope =
    Http.get
        { url = "sample-scope.json"
        , expect = Http.expectJson ScopeLoaded decodeScope
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputChanged inputName value ->
            let
                newModel =
                    { model | inputValues = Dict.insert inputName value model.inputValues }
            in
            ( autoEvaluate newModel, Cmd.none )

        ScopeLoaded (Ok scope) ->
            let
                newModel =
                    { model
                        | scope = Just scope
                        , scopeLoadingState = LoadSuccess
                    }
            in
            ( autoEvaluate newModel, Cmd.none )

        ScopeLoaded (Err error) ->
            ( { model
                | scopeLoadingState = LoadError (httpErrorToString error)
              }
            , Cmd.none
            )


{-| Automatically evaluate the scope if possible
-}
autoEvaluate : Model -> Model
autoEvaluate model =
    case model.scope of
        Nothing ->
            { model | evaluationResult = Nothing }

        Just scope ->
            let
                context =
                    buildContext
                        scope
                        model.inputValues

                result =
                    case context of
                        Ok ctx ->
                            Just (evaluateScope ctx scope)

                        Err err ->
                            Just (Err err)
            in
            { model | evaluationResult = result }


{-| Convert HTTP error to string
-}
httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "Bad URL: " ++ url

        Http.Timeout ->
            "Request timed out"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus status ->
            "HTTP error: " ++ String.fromInt status

        Http.BadBody body ->
            "Bad response body: " ++ body


{-| Build evaluation context from input values
-}
buildContext : Scope -> Dict String String -> Result String (Dict String Expression)
buildContext scope inputValues =
    buildContextHelper scope.inputs inputValues Dict.empty
        |> Result.andThen (\ctx -> calculateDataPoints ctx scope.calculations)


buildContextHelper : List Input -> Dict String String -> Dict String Expression -> Result String (Dict String Expression)
buildContextHelper inputs inputValues context =
    case inputs of
        [] ->
            Ok context

        input :: remainingInputs ->
            case Dict.get input.name inputValues of
                Nothing ->
                    Err ("Missing input: " ++ input.name)

                Just stringValue ->
                    case parseInputValue input.type_ stringValue of
                        Ok expr ->
                            buildContextHelper remainingInputs inputValues (Dict.insert input.name expr context)

                        Err err ->
                            Err err


{-| Parse string input value according to expected type
-}
parseInputValue : Type -> String -> Result String Expression
parseInputValue expectedType stringValue =
    case expectedType of
        StringType ->
            Ok (LiteralExpr (StringLiteral stringValue))

        NumberType ->
            case String.toFloat stringValue of
                Just num ->
                    Ok (LiteralExpr (NumberLiteral num))

                Nothing ->
                    Err ("Invalid number: " ++ stringValue)

        BoolType ->
            case String.toLower stringValue of
                "true" ->
                    Ok (LiteralExpr (BoolLiteral True))

                "false" ->
                    Ok (LiteralExpr (BoolLiteral False))

                _ ->
                    Err ("Invalid boolean (use 'true' or 'false'): " ++ stringValue)



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "scope-viewer" ]
        [ h1 [] [ text "Pluraal Scope Viewer ..." ]
        , case model.scopeLoadingState of
            Loading ->
                div [ class "loading" ]
                    [ text "Loading scope definition..." ]

            LoadError error ->
                div [ class "error" ]
                    [ h2 [] [ text "Error Loading Scope" ]
                    , p [] [ text error ]
                    ]

            LoadSuccess ->
                case model.scope of
                    Nothing ->
                        div [ class "error" ]
                            [ text "Scope loaded but not available" ]

                    Just scope ->
                        let
                            -- Build context for highlighting active branches
                            context =
                                buildContext scope model.inputValues
                                    |> Result.toMaybe
                        in
                        div [ class "scope-container" ]
                            [ viewScopeDefinitionWithContext context model.inputValues scope ]
        ]


viewScopeDefinitionWithContext : Maybe (Dict String Expression) -> Dict String String -> Scope -> Html Msg
viewScopeDefinitionWithContext context inputValues scope =
    div [ class "scope-definition", style "width" "100%" ]
        [ h2 [] [ text "Scope Definition" ]
        , div [ class "inputs-section" ]
            [ h3 [] [ text "Inputs" ]
            , ul [] (List.map (viewInputDefinitionWithControl inputValues) scope.inputs)
            ]
        , div [ class "datapoints-section" ]
            [ h3 [] [ text "Calculations" ]
            , ul []
                (scope.calculations
                    |> Dict.toList
                    |> List.map (viewDataPointDefinitionFromPairWithVisibility context scope.outputs)
                )
            ]
        ]


{-| Render input definition with its control right below it
-}
viewInputDefinitionWithControl : Dict String String -> Input -> Html Msg
viewInputDefinitionWithControl inputValues inputDef =
    let
        maybeRaw =
            Dict.get inputDef.name inputValues

        trimmed =
            maybeRaw |> Maybe.map String.trim |> Maybe.withDefault ""

        maybeError =
            if trimmed == "" then
                Just "Required"

            else
                case parseInputValue inputDef.type_ trimmed of
                    Ok _ ->
                        Nothing

                    Err e ->
                        Just e
    in
    li [ class "input-definition-with-control" ]
        [ div [ class "input-definition" ]
            [ strong [] [ text inputDef.name ]
            , text ": "
            , span [ class "type" ] [ text (typeToString inputDef.type_) ]
            ]
        , div [ class "input-control" ]
            [ case inputDef.type_ of
                BoolType ->
                    let
                        groupName =
                            inputDef.name

                        isTrue =
                            maybeRaw == Just "true"

                        isFalse =
                            maybeRaw == Just "false"
                    in
                    div [ class "radio-group boolean" ]
                        [ label [ class "radio-option" ]
                            [ input
                                [ type_ "radio"
                                , name groupName
                                , value "true"
                                , checked isTrue
                                , onInput (InputChanged inputDef.name)
                                ]
                                []
                            , text " Yes"
                            ]
                        , label [ class "radio-option" ]
                            [ input
                                [ type_ "radio"
                                , name groupName
                                , value "false"
                                , checked isFalse
                                , onInput (InputChanged inputDef.name)
                                ]
                                []
                            , text " No"
                            ]
                        , case maybeError of
                            Just msg ->
                                span [ class "input-error" ] [ text (" — " ++ msg) ]

                            Nothing ->
                                text ""
                        ]

                _ ->
                    label []
                        [ input
                            [ type_ "text"
                            , value (Dict.get inputDef.name inputValues |> Maybe.withDefault "")
                            , onInput (InputChanged inputDef.name)
                            , placeholder (getPlaceholder inputDef.type_)
                            ]
                            []
                        , case maybeError of
                            Just msg ->
                                span [ class "input-error" ] [ text (" — " ++ msg) ]

                            Nothing ->
                                text ""
                        ]
            ]
        ]


viewDataPointDefinitionFromPairWithVisibility : Maybe (Dict String Expression) -> Set String -> ( String, Expression ) -> Html Msg
viewDataPointDefinitionFromPairWithVisibility context outputs ( name, expression ) =
    let
        isPublic =
            Set.member name outputs

        visibilityClass =
            if isPublic then
                "public-datapoint"

            else
                "private-datapoint"

        visibilityIcon =
            if isPublic then
                "🌐"

            else
                "🔒"

        visibilityLabel =
            if isPublic then
                "public"

            else
                "private"

        computedValueNode =
            case context of
                Just ctx ->
                    case Dict.get name ctx of
                        Just valExpr ->
                            span [ class "computed-value" ] [ viewExpression Nothing valExpr ]

                        Nothing ->
                            span [ class "computed-value missing" ] [ text "?" ]

                Nothing ->
                    span [ class "computed-value missing" ] [ text "?" ]
    in
    li [ class ("data-point " ++ visibilityClass) ]
        [ span [ class "visibility-indicator", title visibilityLabel ] [ text visibilityIcon ]
        , strong [] [ text name ]
        , span [ class "visibility-label" ] [ text (" (" ++ visibilityLabel ++ ")") ]
        , text " = "
        , computedValueNode
        , div [ class "expression" ] [ viewExpression context expression ]
        ]



-- Removed separate Evaluation Result section; results are shown inline next to data points.
-- HELPERS


typeToString : Type -> String
typeToString type_ =
    case type_ of
        StringType ->
            "String"

        NumberType ->
            "Number"

        BoolType ->
            "Boolean"


getPlaceholder : Type -> String
getPlaceholder type_ =
    case type_ of
        StringType ->
            "Enter text..."

        NumberType ->
            "Enter number..."

        BoolType ->
            "true or false"



-- EXPRESSION VISUALIZATION


{-| Render an expression as HTML DOM nodes with optional evaluation context for highlighting
-}
viewExpression : Maybe (Dict String Expression) -> Expression -> Html Msg
viewExpression context expr =
    case expr of
        LiteralExpr literal ->
            viewLiteral literal

        Reference name ->
            span [ class "variable" ] [ text name ]

        BranchExpr branch ->
            viewBranch context branch


{-| Render a literal value
-}
viewLiteral : Literal -> Html Msg
viewLiteral literal =
    case literal of
        StringLiteral str ->
            span [ class "literal string-literal" ] [ text ("\"" ++ str ++ "\"") ]

        NumberLiteral num ->
            span [ class "literal number-literal" ] [ text (String.fromFloat num) ]

        BoolLiteral bool ->
            span [ class "literal bool-literal" ]
                [ text
                    (if bool then
                        "true"

                     else
                        "false"
                    )
                ]


{-| Render a branch as structured DOM with evaluation context for highlighting
-}
viewBranch : Maybe (Dict String Expression) -> Branch -> Html Msg
viewBranch context branch =
    case branch of
        IfThenElseBranch ifThenElse ->
            viewIfThenElse context ifThenElse

        RuleChainBranch ruleChain ->
            viewRuleChain context ruleChain

        FiniteBranchBranch finiteBranch ->
            viewFiniteBranch context finiteBranch


{-| Render an if-then-else branch as a directory tree structure with highlighting
-}
viewIfThenElse : Maybe (Dict String Expression) -> IfThenElse -> Html Msg
viewIfThenElse context { condition, then_, else_ } =
    let
        -- Determine which branch is taken based on evaluation
        activeBranch =
            context
                |> Maybe.andThen
                    (\ctx ->
                        case evaluate ctx condition of
                            Ok (LiteralExpr (BoolLiteral True)) ->
                                Just "yes"

                            Ok (LiteralExpr (BoolLiteral False)) ->
                                Just "no"

                            _ ->
                                Nothing
                    )

        yesClass =
            if activeBranch == Just "yes" then
                "tree-line child-line active-branch"

            else
                "tree-line child-line"

        noClass =
            if activeBranch == Just "no" then
                "tree-line child-line last-child active-branch"

            else
                "tree-line child-line last-child"
    in
    div [ class "branch if-then-else-tree" ]
        [ div [ class "tree-root" ]
            [ div [ class "tree-line root-line" ]
                [ span [ class "tree-icon root-icon" ] [ text "📋" ]
                , span [ class "tree-label" ] [ text "condition:" ]
                , span [ class "tree-content" ] [ viewExpression context condition ]
                ]
            , div [ class yesClass ]
                [ span [ class "tree-connector" ] [ text "├─" ]
                , span [ class "tree-icon yes-icon" ] [ text "✅" ]
                , span [ class "tree-label" ] [ text "yes:" ]
                , span [ class "tree-content" ] [ viewExpression context then_ ]
                ]
            , div [ class noClass ]
                [ span [ class "tree-connector" ] [ text "└─" ]
                , span [ class "tree-icon no-icon" ] [ text "❌" ]
                , span [ class "tree-label" ] [ text "no:" ]
                , span [ class "tree-content" ] [ viewExpression context else_ ]
                ]
            ]
        ]


{-| Render a rule chain as a directory tree structure with highlighting
-}
viewRuleChain : Maybe (Dict String Expression) -> RuleChain -> Html Msg
viewRuleChain context { rules, otherwise } =
    let
        -- Check which rules are satisfied to determine if otherwise branch should be active
        satisfiedRules =
            context
                |> Maybe.map
                    (\ctx ->
                        rules
                            |> List.map
                                (\rule ->
                                    case evaluate ctx rule.when of
                                        Ok (LiteralExpr (BoolLiteral True)) ->
                                            True

                                        _ ->
                                            False
                                )
                    )
                |> Maybe.withDefault []

        hasMatchingRule =
            List.any identity satisfiedRules

        -- Otherwise is active only when we have a context and no rules match
        isOtherwiseActive =
            context /= Nothing && not hasMatchingRule

        ruleElements =
            List.indexedMap (viewRuleInChain context) rules

        otherwiseElement =
            case otherwise of
                Nothing ->
                    []

                Just expr ->
                    let
                        othClass =
                            if isOtherwiseActive then
                                "tree-line child-line last-child active-branch"

                            else
                                "tree-line child-line last-child"
                    in
                    [ div [ class othClass ]
                        [ span [ class "tree-connector" ] [ text "└─" ]
                        , span [ class "tree-icon" ] [ text "🔄" ]
                        , span [ class "tree-label" ] [ text "otherwise:" ]
                        , span [ class "tree-content" ] [ viewExpression context expr ]
                        ]
                    ]
    in
    div [ class "branch rule-chain-tree" ]
        [ div [ class "tree-root" ]
            (div [ class "tree-line root-line" ]
                [ span [ class "tree-icon root-icon" ] [ text "📋" ]
                , span [ class "tree-label" ] [ text "rules:" ]
                , span [ class "tree-content rule-count" ] [ text (String.fromInt (List.length rules) ++ " rule(s)") ]
                ]
                :: ruleElements
                ++ otherwiseElement
            )
        ]


{-| Render a single rule in a chain with proper tree connectors and highlighting
-}
viewRuleInChain : Maybe (Dict String Expression) -> Int -> Rule -> Html Msg
viewRuleInChain context index { when, then_ } =
    let
        connector =
            "├─"

        -- Check if this rule's condition is satisfied
        isActive =
            context
                |> Maybe.andThen
                    (\ctx ->
                        case evaluate ctx when of
                            Ok (LiteralExpr (BoolLiteral True)) ->
                                Just True

                            _ ->
                                Nothing
                    )
                |> Maybe.withDefault False

        lineClass =
            if isActive then
                "tree-line child-line active-branch"

            else
                "tree-line child-line"
    in
    div [ class lineClass ]
        [ span [ class "tree-connector" ] [ text connector ]
        , span [ class "tree-icon" ] [ text "⚡" ]
        , span [ class "tree-label" ] [ text ("rule " ++ String.fromInt (index + 1) ++ ":") ]
        , div [ class "tree-content rule-content" ]
            [ div [ class "rule-part" ]
                [ span [ class "rule-keyword" ] [ text "when " ]
                , viewExpression context when
                ]
            , div [ class "rule-part" ]
                [ span [ class "rule-keyword" ] [ text "then " ]
                , viewExpression context then_
                ]
            ]
        ]


{-| Render a finite branch as a directory tree structure with highlighting
-}
viewFiniteBranch : Maybe (Dict String Expression) -> FiniteBranch -> Html Msg
viewFiniteBranch context { branchOn, cases, otherwise } =
    let
        -- Determine which case is active based on the switch value
        switchValue : Maybe Expression
        switchValue =
            context
                |> Maybe.andThen
                    (\ctx ->
                        case evaluate ctx branchOn of
                            Ok exp ->
                                Just exp

                            _ ->
                                Nothing
                    )

        -- Check if any case matches the switch value
        hasMatchingCase : Bool
        hasMatchingCase =
            context
                |> Maybe.map
                    (\ctx ->
                        case evaluate ctx branchOn of
                            Ok switchVal ->
                                cases
                                    |> List.any
                                        (\( caseKey, _ ) ->
                                            case evaluate ctx caseKey of
                                                Ok evaluatedKey ->
                                                    switchVal == evaluatedKey

                                                _ ->
                                                    False
                                        )

                            _ ->
                                False
                    )
                |> Maybe.withDefault False

        -- Otherwise is active when we have a context, a switch value, but no matching case
        isOtherwiseActive =
            context /= Nothing && switchValue /= Nothing && not hasMatchingCase

        caseElements =
            cases
                |> List.indexedMap (viewCaseInTreeFromPair context switchValue)

        otherwiseElement =
            case otherwise of
                Nothing ->
                    []

                Just expr ->
                    let
                        othClass =
                            if isOtherwiseActive then
                                "tree-line child-line last-child active-branch"

                            else
                                "tree-line child-line last-child"
                    in
                    [ div [ class othClass ]
                        [ span [ class "tree-connector" ] [ text "└─" ]
                        , span [ class "tree-icon" ] [ text "🔄" ]
                        , span [ class "tree-label" ] [ text "default:" ]
                        , span [ class "tree-content" ] [ viewExpression context expr ]
                        ]
                    ]
    in
    div [ class "branch finite-branch-tree" ]
        [ div [ class "tree-root" ]
            (div [ class "tree-line root-line" ]
                [ span [ class "tree-icon root-icon" ] [ text "📋" ]
                , span [ class "tree-label" ] [ text "switch on:" ]
                , span [ class "tree-content" ] [ viewExpression context branchOn ]
                ]
                :: caseElements
                ++ otherwiseElement
            )
        ]


{-| Render a case in a finite branch tree with highlighting (from pair format)
-}
viewCaseInTreeFromPair : Maybe (Dict String Expression) -> Maybe Expression -> Int -> ( Expression, Expression ) -> Html Msg
viewCaseInTreeFromPair context switchValue _ ( key, expr ) =
    let
        -- Check if this case key matches the switch value
        isActive : Bool
        isActive =
            case ( context, switchValue ) of
                ( Just ctx, Just switchExp ) ->
                    case ( evaluate ctx key, evaluate ctx switchExp ) of
                        ( Ok evaluatedKey, Ok evaluatedSwitch ) ->
                            evaluatedKey == evaluatedSwitch

                        _ ->
                            False

                _ ->
                    False

        lineClass =
            if isActive then
                "tree-line child-line active-branch"

            else
                "tree-line child-line"

        keyLabel =
            case key of
                LiteralExpr (StringLiteral str) ->
                    "case \"" ++ str ++ "\""

                LiteralExpr (NumberLiteral num) ->
                    "case " ++ String.fromFloat num

                LiteralExpr (BoolLiteral bool) ->
                    "case "
                        ++ (if bool then
                                "true"

                            else
                                "false"
                           )

                Reference name ->
                    "case " ++ name

                _ ->
                    "case [expression]"
    in
    div [ class lineClass ]
        [ span [ class "tree-connector" ] [ text "├─" ]
        , span [ class "tree-icon" ] [ text "🎯" ]
        , span [ class "tree-label" ] [ text (keyLabel ++ ":") ]
        , span [ class "tree-content" ] [ viewExpression context expr ]
        ]



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
