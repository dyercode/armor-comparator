module Main exposing (..)

import Browser
import Html exposing (Attribute, Html, button, div, h2, input, label, li, section, select, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (checked, for, id, name, scope, type_, value)
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
    | Null
    | ArmorSelected String
    | AddArmor
    | NewUuid


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Null ->
            ( model, Cmd.none )

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
                            EnchantedArmor arm defaultModifications (Uuid.toString uuid)
                    in
                    ( { model | enchantedArmors = newArmor :: model.enchantedArmors }, Cmd.none )
                        |> andThen update NewUuid

                _ ->
                    ( model, Cmd.none )

        NewUuid ->
            let
                ( newUuid, newSeed ) =
                    step Uuid.generator model.currentSeed
            in
            -- 2.: Store the new seed
            ( { model
                | currentUuid = Just newUuid
                , currentSeed = newSeed
              }
            , Cmd.none
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
    div [] [ characterSection model, armorComponent model ]


type alias Model =
    { dexMod : Int
    , flyingClassSkill : Bool
    , flyingRanks : Int
    , autoSort : Bool
    , enchantedArmors : List EnchantedArmor
    , selectedArmor : Maybe Armor
    , currentSeed : Seed
    , currentUuid : Maybe Uuid.Uuid
    }


type alias Character r =
    { r
        | dexMod : Int
        , flyingClassSkill : Bool
        , flyingRanks : Int
    }


type alias Armor =
    { name : String
    , armor : Int
    , maxDex : Int
    , checkPenalty : Int
    , cost : Int
    }


type alias Modifications =
    { enhancement : Int
    , mithral : Bool
    , comfortable : Bool
    }


defaultModifications : Modifications
defaultModifications =
    { enhancement = 0, mithral = False, comfortable = False }


type EnchantedArmor
    = EnchantedArmor Armor Modifications String


armory : List Armor
armory =
    [ { name = "Full plate", armor = 9, maxDex = 1, checkPenalty = -6, cost = 1500 }
    , { name = "Half-plate", armor = 8, maxDex = 0, checkPenalty = -7, cost = 600 }
    , { name = "Banded mail", armor = 7, maxDex = 1, checkPenalty = -6, cost = 250 }
    ]


armorComponent : Model -> Html Msg
armorComponent model =
    section [ id "armor" ]
        [ h2 []
            [ text "Armor Comparison" ]
        , armorAdder model
        , armorList model model.enchantedArmors
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
                , Html.Events.onInput ArmorSelected
                ]
                (map (armorOption model) armory)
            , button
                [ id "add-armor"
                , onClick AddArmor
                ]
                [ text "Add" ]
            , li []
                [ label [ for "auto-sort" ] [ text "Auto-sort" ]
                , input [ type_ "checkbox", id "auto-sort", checked model.autoSort ] []
                ]
            ]
        ]


armorList : Character r -> List EnchantedArmor -> Html Msg
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


armorEntry : Character r -> EnchantedArmor -> Html Msg
armorEntry character ea =
    tr []
        [ td [] [ text <| getName ea ]
        , td [] [ text <| plusify <| totalArmor ea character ]
        , td [] [ text <| String.fromInt <| totalCheckPenalty ea ]
        , td [] [ text "cost" ]
        , td [] [ text "flightBonus" ]
        , td [] [ text "enhancement dropdown" ]
        , td [] [ input [ type_ "checkbox", checked <| isComfortable ea ] [] ]
        , td [] [ input [ type_ "checkbox", checked <| isMithral ea ] [] ]
        , td [] [ text <| "remove button for " ++ getId ea ]
        ]


getId : EnchantedArmor -> String
getId (EnchantedArmor _ _ id) =
    id


getName : EnchantedArmor -> String
getName (EnchantedArmor a _ _) =
    a.name


getArmor : EnchantedArmor -> Int
getArmor (EnchantedArmor a _ _) =
    a.armor


getMaxDex : EnchantedArmor -> Int
getMaxDex (EnchantedArmor a _ _) =
    a.maxDex


getCheckPenalty : EnchantedArmor -> Int
getCheckPenalty (EnchantedArmor a _ _) =
    a.checkPenalty


isMithral : EnchantedArmor -> Bool
isMithral (EnchantedArmor _ m _) =
    m.mithral


isComfortable : EnchantedArmor -> Bool
isComfortable (EnchantedArmor _ m _) =
    m.comfortable


getEnhancement : EnchantedArmor -> Int
getEnhancement (EnchantedArmor _ m _) =
    m.enhancement


totalMaxDex : EnchantedArmor -> Int
totalMaxDex ea =
    let
        mithralBonus =
            if isMithral ea then
                2

            else
                0
    in
    getMaxDex ea + mithralBonus


totalArmorOld : EnchantedArmor -> Character r -> Int
totalArmorOld ea character =
    getArmor ea
        + min (totalMaxDex ea) character.dexMod
        + getEnhancement ea


totalArmor : EnchantedArmor -> Character r -> Int
totalArmor ea character =
    [ getArmor
    , min character.dexMod << totalMaxDex
    , getEnhancement
    ]
        |> map ((|>) ea)
        |> List.sum


totalCheckPenalty : EnchantedArmor -> Int
totalCheckPenalty ea =
    let
        mithralModifier =
            if isMithral ea then
                3

            else
                0

        comfortableModifier =
            if isComfortable ea then
                1

            else
                0
    in
    getCheckPenalty ea + mithralModifier + comfortableModifier


plusify : Int -> String
plusify i =
    if i < 0 then
        String.fromInt i

    else
        "+" ++ String.fromInt i



--     </ul>
--     <table id="armor-comparison-table">
--         <thead>
--             <tr>
--                 <th scope="col">Type</th>
--                 <th scope="col">Total AC Bonus</th>
--                 <th scope="col">Armor Check Penalty</th>
--                 <th scope="col">Cost</th>
--                 <th scope="col">Fly Skill Bonus</th>
--                 <th scope="col">Enchantment Level</th>
--                 <th scope="col">Comfortable</th>
--                 <th scope="col">Mithral</th>
--                 <th scope="col" />
--             </tr>
--         </thead>
--         <tbody data-bind="foreach: autoSort() ? sortedArmors() : comparedArmors">
--             <tr>
--                 <td><span data-bind="text: name" /></td>
--                 <td data-bind="text: $parent.totalArmorRaw($data, $parent.character())"></td>
--                 <td data-bind="text: totalCheckPenalty()"></td>
--                 <td><span data-bind="text: totalCost($parent.enhancements)"></span>gp</td>
--                 <td data-bind="text: $parent.flightBonus($data, $parent.character())"></td>
--                 <td><select data-bind="value: selectedEnhancement,
-- 										 options: $parent.enhancements,
-- 										 optionsText: function(armor) {return '+' + armor.bonus},
-- 								 optionsValue: 'bonus'"></select></td>
--                 <td><input type="checkbox" data-bind="checked: comfortable" /></td>
--                 <td><input type="checkbox" data-bind="checked: mithral" /></td>
--                 <td><button data-bind="click: $parent.remove">Remove</button></td>
--             </tr>
--         </tbody>
--     </table>
