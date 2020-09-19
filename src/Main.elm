module Main exposing (main)

import Browser
import Html exposing (Attribute, Html, a, dd, div, dt, h1, h2, h3, header, input, label, li, p, section, text, ul)
import Html.Attributes exposing (attribute, class, href, id, name, type_, value)
import Html.Events exposing (onCheck, onInput)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( defaultModel, Cmd.none )


type Msg
    = DexMod String
    | ClassSkillToggle Bool
    | FlyingRanks String


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        DexMod str ->
            case String.toInt str of
                Just num ->
                    ( { model | dexMod = num }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        ClassSkillToggle b ->
            ( { model | flyingClassSkill = b }
            , Cmd.none
            )

        FlyingRanks str ->
            case String.toInt str of
                Just num ->
                    ( { model | flyingRanks = num }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )


defaultModel : Model
defaultModel =
    { dexMod = 0, flyingClassSkill = False, flyingRanks = 0 }


characterSection : Character r -> Html Msg
characterSection character =
    section [ attribute "id" "Character" ]
        [ h2 [] [ text "Player Info" ]
        , ul []
            [ li []
                [ label [ attribute "for" "dexmod" ] [ text "Dex Modifier" ]
                , input
                    [ id "dexmod"
                    , name "dexmod"
                    , Html.Attributes.type_ "number"
                    , value (String.fromInt character.dexMod)
                    , onInput DexMod
                    ]
                    []
                ]
            , li []
                [ label [ attribute "for" "is-fly-class-skill" ] [ text "Fly class skill?" ]
                , input
                    [ type_ "checkbox"
                    , id "is-fly-class-skill"
                    , Html.Attributes.checked character.flyingClassSkill
                    , onCheck ClassSkillToggle
                    ]
                    []
                ]
            , li []
                [ label [ id "points-in-fly" ] [ text "Points in fly" ]
                , input
                    [ type_ "number"
                    , id "points-in-fly"
                    , value (String.fromInt character.flyingRanks)
                    , onInput FlyingRanks
                    ]
                    []
                ]
            ]
        , li [] [ text <| "Base Fly Skill: " ++ String.fromInt (flyingBeforeCheckPenalty character) ]
        ]


flyingBeforeCheckPenalty : Character r -> Int
flyingBeforeCheckPenalty c =
    let
        pointsFromClass =
            if c.flyingClassSkill && c.flyingRanks > 0 then
                3

            else
                0
    in
    c.dexMod + pointsFromClass + c.flyingRanks


view : Model -> Html Msg
view model =
    div [] [ characterSection model ]


type alias Model =
    { dexMod : Int
    , flyingClassSkill : Bool
    , flyingRanks : Int
    }


type alias Character r =
    { r
        | dexMod : Int
        , flyingClassSkill : Bool
        , flyingRanks : Int
    }
