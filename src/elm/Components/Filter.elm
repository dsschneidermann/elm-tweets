module Components.Filter exposing (..)

import Model exposing (..)


applyFilter : String -> Loadable (List Tweet) -> Loadable (List Tweet)
applyFilter searchTerm tweets =
    case searchTerm of
        "" ->
            tweets

        value ->
            apply value tweets


apply : String -> Loadable (List Tweet) -> Loadable (List Tweet)
apply searchTerm tweets =
    case tweets of
        Initial ->
            Initial

        None ->
            None

        Some items ->
            Some
                (List.filter
                    (\item ->
                        String.contains
                            (String.toLower searchTerm)
                            (String.toLower item.text)
                    )
                    items
                )
