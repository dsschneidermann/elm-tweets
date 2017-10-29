module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Events.Extra exposing (onEnter)
import Http exposing (..)
import Model exposing (..)
import Components.Tweets exposing (..)
import Components.Filter exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchHashtagInput value ->
            ( { model | hashtag = Some value }, Cmd.none )

        SearchHashtag ->
            ( { model
                | showSpinner = True
                , searchedHashtag = None
                , searchTerm = Initial -- input field is cleared when set to this
                , searchedSearchTerm = None
                , tweets = None
                , filteredTweets = None
              }
            , tweetsSearch (model.hashtag |> toNormalString)
            )

        SearchHashtagResult (Ok data) ->
            ( { model
                | searchedHashtag = model.hashtag
                , searchTerm = None
                , tweets = data |> toLoadedValue
                , filteredTweets = data |> toLoadedValue
                , error = None
                , showSpinner = False
              }
            , Cmd.none
            )

        SearchHashtagResult (Err error) ->
            ( { model | error = Some (stringFromHttpError error) }, Cmd.none )

        SearchTermInput value ->
            ( { model | searchTerm = Some value }, Cmd.none )

        SearchTerm ->
            ( { model
                | searchedSearchTerm = model.searchTerm
                , filteredTweets =
                    applyFilter
                        (model.searchTerm |> toNormalString)
                        model.tweets
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


stringFromHttpError : Http.Error -> String
stringFromHttpError e =
    case e of
        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Network Error"

        Http.BadPayload msg resp ->
            "Bad Payload: " ++ msg

        Http.BadStatus resp ->
            "Bad Status: " ++ (toString resp)

        Http.BadUrl msg ->
            "Bad Url: " ++ msg


view : Model -> Html Msg
view model =
    div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
        [ div [ class "row" ]
            [ div [ class "col-xs-12" ]
                [ div [ class "jumbotron" ]
                    [ img [ src "static/img/elm.jpg", style [ ( "width", "33%" ), ( "max-width", "250px" ), ( "border", "4px solid #337AB7" ) ] ] []
                    , p [ style [ ( "color", "red" ) ] ] [ text (model.error |> toNormalString) ]
                    , div []
                        [ i [] [ text "# " ]
                        , input
                            [ type_ "text"
                            , placeholder "hashtag"
                            , onInput SearchHashtagInput
                            , onEnter SearchHashtag
                            , style [ ( "margin-right", "5px" ) ]
                            ]
                            []
                        , button [ class "btn btn-primary btn-sm", onClick SearchHashtag ]
                            [ span [ class "glyphicon glyphicon-star" ] []
                            , span [] [ text "Go!" ]
                            ]
                        ]
                    ]
                , div []
                    (List.concat
                        [ renderTitle (model.searchedHashtag |> toNormalString)
                        , renderFilterInput model
                        , renderTweets
                            (model.searchedSearchTerm |> toNormalString)
                            model.filteredTweets
                        , renderSpinner model.showSpinner
                        , renderPagination model
                        ]
                    )
                ]
            ]
        ]


renderFilterInput : Model -> List (Html Msg)
renderFilterInput model =
    case model.tweets of
        Initial ->
            []

        None ->
            []

        Some [] ->
            []

        Some _ ->
            [ div []
                [ input
                    ([ type_ "text"
                     , placeholder "filter by"
                     , onInput SearchTermInput
                     , onEnter SearchTerm
                     , style [ ( "margin-right", "5px" ) ]
                     ]
                        ++ (clearInputWhenInitial model.searchTerm)
                    )
                    []
                , button [ class "btn btn-primary btn-sm", onClick SearchTerm ]
                    [ span [ class "glyphicon glyphicon-star" ] []
                    , span [] [ text "Do!" ]
                    ]
                ]
            ]


clearInputWhenInitial : Loadable String -> List (Attribute Msg)
clearInputWhenInitial str =
    case str of
        Initial ->
            [ value "" ]

        None ->
            []

        Some _ ->
            []


toNormalString : Loadable String -> String
toNormalString str =
    case str of
        Initial ->
            ""

        None ->
            ""

        Some value ->
            value


toLoadedValue : Maybe a -> Loadable a
toLoadedValue option =
    case option of
        Nothing ->
            Initial

        Just value ->
            Some value
