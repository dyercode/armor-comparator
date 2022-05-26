module Main exposing (formatPrice, main, plusify)

import Browser
import Calculates
    exposing
        ( Armor
        , Character
        , EnchantedArmor(..)
        , Modifications
        , flightBonus
        , flyingBeforeCheckPenalty
        , getCost
        , getEnhancement
        , getName
        , isComfortable
        , isMithral
        , setComfortable
        , setMithral
        , sortArmor
        , totalArmor
        , totalCheckPenalty
        , updateEnhancement
        )
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (Decimals(..), usLocale)
import Html exposing (Html, button, div, h2, input, label, li, section, select, span, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (checked, for, id, name, scope, style, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import List exposing (map)
import Prng.Uuid as Uuid
import Random.Pcg.Extended exposing (Seed, initialSeed, step)
import Update.Extra exposing (andThen)


main : Program ( Int, List Int ) Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : ( Int, List Int ) -> ( Model, Cmd Msg )
init ( seed, seedExtension ) =
    ( { dexMod = 0
      , flyingClassSkill = False
      , flyingRanks = 0
      , autoSort = True
      , enchantedArmors = []
      , selectedArmor = List.head armory
      , currentSeed = initialSeed seed seedExtension
      , currentUuid = Nothing
      }
    , Cmd.none
    )
        |> andThen update NewUuid


type Msg
    = DexMod String
    | ClassSkillToggle Bool
    | FlyingRanks String
    | ArmorSelected String
    | AddArmor
    | NewUuid
    | ChangeSort Bool
    | ChangeComfortable String Bool
    | ChangeMithral String Bool
    | Remove String
    | IncrementEnhancement String
    | DecrementEnhancement String


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        DexMod input ->
            case String.toInt input of
                Just newDexMod ->
                    ( { model | dexMod = newDexMod }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        ClassSkillToggle b ->
            ( { model | flyingClassSkill = b }, Cmd.none )

        FlyingRanks str ->
            case String.toInt str of
                Just num ->
                    ( { model | flyingRanks = num }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        ArmorSelected name ->
            let
                newArm =
                    List.filter (\a -> a.name == name) armory |> List.head
            in
            ( { model | selectedArmor = newArm }, Cmd.none )

        AddArmor ->
            case ( model.selectedArmor, model.currentUuid ) of
                ( Just arm, Just uuid ) ->
                    let
                        newArmor =
                            EnchantedArmor arm defaultModifications
                    in
                    ( { model | enchantedArmors = ( newArmor, Uuid.toString uuid ) :: model.enchantedArmors }, Cmd.none )
                        |> andThen update NewUuid

                _ ->
                    ( model, Cmd.none )

        ChangeSort newBool ->
            ( { model | autoSort = newBool }, Cmd.none )

        IncrementEnhancement id ->
            ( { model | enchantedArmors = model.enchantedArmors |> updateById id (updateEnhancement ((+) 1)) }, Cmd.none )

        DecrementEnhancement id ->
            ( { model | enchantedArmors = model.enchantedArmors |> updateById id (updateEnhancement ((+) -1)) }, Cmd.none )

        ChangeComfortable armorId newValue ->
            ( { model
                | enchantedArmors =
                    model.enchantedArmors
                        |> updateById armorId (setComfortable newValue)
              }
            , Cmd.none
            )

        ChangeMithral armorId newValue ->
            ( { model
                | enchantedArmors =
                    model.enchantedArmors
                        |> updateById armorId (setMithral newValue)
              }
            , Cmd.none
            )

        NewUuid ->
            let
                ( newUuid, newSeed ) =
                    step Uuid.generator model.currentSeed
            in
            ( { model
                | currentUuid = Just newUuid
                , currentSeed = newSeed
              }
            , Cmd.none
            )

        Remove armorId ->
            ( { model | enchantedArmors = List.filter (\( _, id ) -> id /= armorId) model.enchantedArmors }
            , Cmd.none
            )


updateById : String -> (EnchantedArmor -> EnchantedArmor) -> List ( EnchantedArmor, String ) -> List ( EnchantedArmor, String )
updateById id f list =
    list
        |> List.map
            (\( ea, itemId ) ->
                let
                    newEa =
                        if id == itemId then
                            f ea

                        else
                            ea
                in
                ( newEa, itemId )
            )


characterSection : Character r -> Html Msg
characterSection character =
    section [ id "Character" ]
        [ h2 []
            [ text "Player Info" ]
        , ul []
            [ li []
                [ label [ for "dexmod" ] [ text "Dex Modifier" ]
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
                [ label [ for "is-fly-class-skill" ] [ text "Fly class skill?" ]
                , input
                    [ type_ "checkbox"
                    , id "is-fly-class-skill"
                    , Html.Attributes.checked character.flyingClassSkill
                    , onCheck ClassSkillToggle
                    ]
                    []
                ]
            , li []
                [ label [ for "points-in-fly" ] [ text "Points in fly" ]
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


view : Model -> Html Msg
view model =
    div [] [ characterSection model, armorSection model ]


type alias Model =
    { dexMod : Int
    , flyingClassSkill : Bool
    , flyingRanks : Int
    , autoSort : Bool
    , enchantedArmors : List ( EnchantedArmor, String )
    , selectedArmor : Maybe Armor
    , currentSeed : Seed
    , currentUuid : Maybe Uuid.Uuid
    }


defaultModifications : Modifications
defaultModifications =
    { enhancement = 0, mithral = False, comfortable = False }


armory : List Armor
armory =
    [ { name = "Full plate", armor = 9, maxDex = 1, checkPenalty = -6, cost = 1500 }
    , { name = "Half-plate", armor = 8, maxDex = 0, checkPenalty = -7, cost = 600 }
    , { name = "Banded mail", armor = 7, maxDex = 1, checkPenalty = -6, cost = 250 }
    ]


armorSection : Model -> Html Msg
armorSection model =
    section [ id "armor" ]
        [ h2 []
            [ text "Armor Comparison" ]
        , armorAdder model
        , armorList model
            (if model.autoSort then
                sortArmor model.enchantedArmors model

             else
                model.enchantedArmors
            )
        ]


armorOption : Model -> Armor -> Html Msg
armorOption model arm =
    Html.option
        [ value arm.name
        , Html.Attributes.selected
            (case model.selectedArmor of
                Just n ->
                    n.name == arm.name

                Nothing ->
                    False
            )
        ]
        [ text arm.name ]


armorAdder : Model -> Html Msg
armorAdder model =
    ul []
        [ li []
            [ label [ for "compare-selector" ] []
            , select
                [ id "compare-selector"
                , onInput ArmorSelected
                ]
                (map (armorOption model) armory)
            , button
                [ id "add-armor"
                , onClick AddArmor
                ]
                [ text "Add" ]
            , li []
                [ label [ for "auto-sort" ] [ text "Auto-sort" ]
                , input
                    [ type_ "checkbox"
                    , id "auto-sort"
                    , checked model.autoSort
                    , onCheck ChangeSort
                    ]
                    []
                ]
            ]
        ]


armorList : Character r -> List ( EnchantedArmor, String ) -> Html Msg
armorList character armors =
    table [ id "armor-comparison-table" ]
        [ thead []
            [ tr []
                [ th [ scope "col" ] [ text "Type" ]
                , th [ scope "col" ] [ text "Total AC Bonus" ]
                , th [ scope "col" ] [ text "Armor Check Penalty" ]
                , th [ scope "col" ] [ text "Cost" ]
                , th [ scope "col" ] [ text "Fly Skill Bonus" ]
                , th [ scope "col" ] [ text "Enchantment Level" ]
                , th [ scope "col" ] [ text "Comfortable" ]
                , th [ scope "col" ] [ text "Mithral" ]
                , th [ scope "col" ] []
                ]
            ]
        , tbody [] (map (armorEntry character) armors)
        ]


enchantmentSelect : EnchantedArmor -> String -> Html Msg
enchantmentSelect enchantedArmor armorId =
    let
        enh =
            getEnhancement enchantedArmor

        dectainer ih =
            if enh > 0 then
                ih

            else
                text ""

        inctainer ih =
            if enh < 5 then
                ih

            else
                text ""
    in
    div []
        [ div [ style "display" "flex" ]
            (List.map (\e -> div [ style "flex" "1" ] [ e ])
                [ dectainer <| button [ onClick <| DecrementEnhancement armorId ] [ text "-" ]
                , span [] [ text <| plusify (getEnhancement enchantedArmor) ]
                , inctainer <| button [ onClick <| IncrementEnhancement armorId ] [ text "+" ]
                ]
            )
        ]


armorEntry : Character r -> ( EnchantedArmor, String ) -> Html Msg
armorEntry character ( enchantedArmor, armorId ) =
    tr []
        [ td [] [ text <| getName enchantedArmor ]
        , td [] [ text <| plusify <| totalArmor enchantedArmor character ]
        , td [] [ text <| String.fromInt <| totalCheckPenalty enchantedArmor ]
        , td [] [ text <| formatPrice <| getCost enchantedArmor ]
        , td [] [ text <| plusify <| flightBonus enchantedArmor character ]
        , td []
            [ enchantmentSelect enchantedArmor armorId ]
        , td []
            [ input
                [ type_ "checkbox"
                , checked <| isComfortable enchantedArmor
                , onCheck (ChangeComfortable armorId)
                ]
                []
            ]
        , td []
            [ input
                [ type_ "checkbox"
                , checked <| isMithral enchantedArmor
                , onCheck (ChangeMithral armorId)
                ]
                []
            ]
        , td []
            [ button
                [ id ("remove-" ++ armorId)
                , onClick (Remove armorId)
                ]
                [ text "remove" ]
            ]
        ]


plusify : Int -> String
plusify i =
    if i < 0 then
        String.fromInt i

    else
        "+" ++ String.fromInt i


formatPrice : Int -> String
formatPrice i =
    format { usLocale | decimals = Exact 0 } (toFloat i)
