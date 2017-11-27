module Components.Json exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)


type alias Tweet =
    { id : String
    , text : String
    , name : String
    , screen_name : String
    , profile_image_url_https : String
    , created_at : String
    }


tweetDecoder : Decoder Tweet
tweetDecoder =
    decode Tweet
        |> required "id_str" string
        |> required "text" string
        |> required "user" (field "name" string)
        |> required "user" (field "screen_name" string)
        |> required "user" (field "profile_image_url_https" string)
        |> required "created_at" string


resultDecoder : Decoder (Maybe (List Tweet))
resultDecoder =
    maybe
        (field "statuses" (list tweetDecoder))
