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


-- MODEL


type alias Model =
    { scope : Maybe Scope
    , scopeLoadingState : LoadingState
    , inputValues : Dict String String
    , evaluationResult : Maybe (Result String Expression)
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
    | EvaluateScope
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
            ( { model | inputValues = Dict.insert inputName value model.inputValues }
            , Cmd.none
            )

        EvaluateScope ->
            case model.scope of
                Nothing ->
                    ( { model | evaluationResult = Just (Err "No scope loaded") }
                    , Cmd.none
                    )

                Just scope ->
                    let
                        context = buildContext scope.inputs model.inputValues
                        result = case context of
                            Ok ctx -> Just (evaluateScope ctx scope)
                            Err err -> Just (Err err)
                    in
                    ( { model | evaluationResult = result }
                    , Cmd.none
                    )

        ScopeLoaded (Ok scope) ->
            ( { model 
              | scope = Just scope
              , scopeLoadingState = LoadSuccess
              }
            , Cmd.none
            )

        ScopeLoaded (Err error) ->
            ( { model 
              | scopeLoadingState = LoadError (httpErrorToString error)
              }
            , Cmd.none
            )


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
buildContext : List Input -> Dict String String -> Result String (Dict String Expression)
buildContext inputs inputValues =
    buildContextHelper inputs inputValues Dict.empty


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
        [ h1 [] [ text "Pluraal Scope Viewer" ]
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
                        div [ class "scope-container" ]
                            [ viewScopeDefinition scope
                            , viewInputs scope.inputs model.inputValues
                            , viewEvaluationButton
                            , viewResult model.evaluationResult
                            ]
        ]


viewScopeDefinition : Scope -> Html Msg
viewScopeDefinition scope =
    div [ class "scope-definition" ]
        [ h2 [] [ text "Scope Definition" ]
        , div [ class "inputs-section" ]
            [ h3 [] [ text "Inputs" ]
            , ul [] (List.map viewInputDefinition scope.inputs)
            ]
        , div [ class "datapoints-section" ]
            [ h3 [] [ text "Data Points" ]
            , ul [] (List.map viewDataPointDefinition scope.dataPoints)
            ]
        , div [ class "result-section" ]
            [ h3 [] [ text "Result Expression" ]
            , p [] [ text (expressionToString scope.result) ]
            ]
        ]


viewInputDefinition : Input -> Html Msg
viewInputDefinition input =
    li []
        [ strong [] [ text input.name ]
        , text ": "
        , span [ class "type" ] [ text (typeToString input.type_) ]
        ]


viewDataPointDefinition : DataPoint -> Html Msg
viewDataPointDefinition dataPoint =
    li []
        [ strong [] [ text dataPoint.name ]
        , text " = "
        , span [ class "expression" ] [ text (expressionToString dataPoint.expression) ]
        ]


viewInputs : List Input -> Dict String String -> Html Msg
viewInputs inputs inputValues =
    div [ class "input-form" ]
        [ h2 [] [ text "Provide Input Values" ]
        , div [] (List.map (viewInputField inputValues) inputs)
        ]


viewInputField : Dict String String -> Input -> Html Msg
viewInputField inputValues inputDef =
    div [ class "input-field" ]
        [ label []
            [ text (inputDef.name ++ " (" ++ typeToString inputDef.type_ ++ "):")
            , input
                [ type_ "text"
                , value (Dict.get inputDef.name inputValues |> Maybe.withDefault "")
                , onInput (InputChanged inputDef.name)
                , placeholder (getPlaceholder inputDef.type_)
                ]
                []
            ]
        ]


viewEvaluationButton : Html Msg
viewEvaluationButton =
    div [ class "evaluation-section" ]
        [ button [ onClick EvaluateScope ] [ text "Evaluate Scope" ]
        ]


viewResult : Maybe (Result String Expression) -> Html Msg
viewResult maybeResult =
    div [ class "result-section" ]
        [ h2 [] [ text "Evaluation Result" ]
        , case maybeResult of
            Nothing ->
                p [ class "no-result" ] [ text "Click 'Evaluate Scope' to see the result." ]

            Just (Ok expr) ->
                div [ class "success-result" ]
                    [ p [] [ text "✅ Success!" ]
                    , p [] [ text ("Result: " ++ expressionToString expr) ]
                    ]

            Just (Err error) ->
                div [ class "error-result" ]
                    [ p [] [ text "❌ Error:" ]
                    , p [] [ text error ]
                    ]
        ]


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


expressionToString : Expression -> String
expressionToString expr =
    case expr of
        LiteralExpr literal ->
            literalToString literal

        VariableExpr name ->
            name

        BranchExpr _ ->
            "[Complex branching logic]"


literalToString : Literal -> String
literalToString literal =
    case literal of
        StringLiteral str ->
            "\"" ++ str ++ "\""

        NumberLiteral num ->
            String.fromFloat num

        BoolLiteral bool ->
            if bool then "true" else "false"

        NullLiteral ->
            "null"


-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
