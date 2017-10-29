module Model exposing (..)

import Http exposing (..)


type Loadable a
    = Initial
    | None
    | Some a


type alias Model =
    { hashtag : Loadable String
    , searchedHashtag : Loadable String
    , searchTerm : Loadable String
    , searchedSearchTerm : Loadable String
    , tweets : Loadable (List Tweet)
    , filteredTweets : Loadable (List Tweet)
    , error : Loadable String
    , showSpinner : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( Model Initial Initial Initial Initial Initial Initial Initial False, Cmd.none )


type alias Tweet =
    { id : String
    , text : String
    , name : String
    , screen_name : String
    , profile_image_url_https : String
    , created_at : String
    }


type Msg
    = SearchHashtagInput String
    | SearchHashtag
    | SearchHashtagResult (Result Http.Error (Maybe (List Tweet)))
    | SearchTermInput String
    | SearchTerm
