module Components.Tweets exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode
import Model exposing (..)
import Task exposing (..)


renderTitle : String -> List (Html Msg)
renderTitle resultHashtag =
    case resultHashtag of
        "" ->
            []

        hashtag ->
            [ div [ class "h2" ]
                [ text ("Tweets for: #" ++ hashtag) ]
            ]


renderTweets : String -> Loadable (List Tweet) -> List (Html Msg)
renderTweets highlight tweets =
    case tweets of
        Initial ->
            [ div [ class "h3" ]
                [ text "Go ahead and search" ]
            ]

        None ->
            []

        Some [] ->
            [ div [ class "h3" ]
                [ text "Oh no, no tweets!" ]
            ]

        Some items ->
            [ div [ class "tweets" ]
                (List.map (renderElement highlight) items)
            ]


renderElement : String -> Tweet -> Html a
renderElement highlight item =
    div [ class "EmbeddedTweet-tweet" ]
        [ blockquote [ class "Tweet" ]
            [ div [ class "Tweet-header" ]
                [ div [ class "TweetAuthor" ]
                    [ a
                        [ class "TweetAuthor-link"
                        , href ("https://twitter.com/" ++ item.screen_name)
                        ]
                        [ span [ class "TweetAuthor-avatar" ]
                            [ div [ class "Avatar Avatar--edge" ]
                                [ img [ src item.profile_image_url_https ] [] ]
                            ]
                        , span [ class "TweetAuthor-name" ]
                            [ text item.name
                            ]
                        , span [ class "TweetAuthor-screenName" ]
                            [ text ("@" ++ item.screen_name)
                            ]
                        ]
                    ]
                ]
            , div [ class "Tweet-body" ]
                [ p [ class "Tweet-text" ]
                    [ renderText highlight item.text
                    ]
                , div [ class "Tweet-metadata dateline" ]
                    [ a [ href ("https://twitter.com/" ++ item.screen_name ++ "/status/" ++ item.id) ]
                        [ text item.created_at
                        ]
                    ]
                ]
            ]
        ]


renderText : String -> String -> Html a
renderText highlight str =
    p [] [ text (str) ]


renderSpinner : Bool -> List (Html a)
renderSpinner showSpinner =
    case showSpinner of
        False ->
            []

        True ->
            [ div [ class "h3" ]
                [ text "Spinning..." ]
            ]


renderPagination : Model -> List (Html a)
renderPagination model =
    []


tweetsSearch : String -> Cmd Msg
tweetsSearch hashtag =
    case hashtag of
        "" ->
            -- Reset the list with an empty result
            Task.succeed (SearchHashtagResult (Ok Nothing)) |> Task.perform identity

        hashtag ->
            let
                url =
                    "http://localhost:5000/search/tweets?q=from%3A" ++ hashtag ++ "%20OR%20%23" ++ hashtag
            in
                Http.send SearchHashtagResult (Http.get url resultDecoder)


tweetDecoder : Decode.Decoder Tweet
tweetDecoder =
    Decode.map6 Tweet
        (Decode.field "id_str" Decode.string)
        (Decode.field "text" Decode.string)
        (Decode.at [ "user", "name" ] Decode.string)
        (Decode.at [ "user", "screen_name" ] Decode.string)
        (Decode.at [ "user", "profile_image_url_https" ] Decode.string)
        (Decode.field "created_at" Decode.string)


resultDecoder : Decode.Decoder (Maybe (List Tweet))
resultDecoder =
    Decode.maybe
        (Decode.field "statuses" (Decode.list tweetDecoder))
