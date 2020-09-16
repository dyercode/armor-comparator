module Main exposing (main)

import Browser
import Html exposing (Attribute, Html, a, button, dd, div, dt, h1, h2, h3, header, input, label, li, p, section, select, text, ul)
import Html.Attributes exposing (attribute, class, for, href, id, name, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)


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
    | Null


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


defaultModel : Model
defaultModel =
    { dexMod = 0, flyingClassSkill = False, flyingRanks = 0 }


characterSection : Character r -> Html Msg
characterSection character =
    section [ attribute "id" "Character" ]
        [ h2 [] [ text "Player Info" ]
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


type alias Armor =
    { name : String
    , armor : Int
    , maxDex : Int
    , checkPenalty : Int
    , cost : Int
    }


armory : List Armor
armory =
    [ { name = "Full plate", armor = 9, maxDex = 1, checkPenalty = -6, cost = 1500 }
    , { name = "Half-plate", armor = 8, maxDex = 0, checkPenalty = -7, cost = 600 }
    , { name = "Banded mail", armor = 7, maxDex = 1, checkPenalty = -6, cost = 250 }
    ]


armorComponent : Html Msg
armorComponent =
    section [ id "armor" ]
        [ h2 []
            [ text "Armor Comparison" ]
        , ul []
            [ li []
                [ label [ for "compare-selector" ] []
                , select
                    [ id "compare-selector"
                    , value "selectedArmor"

                    --    options: armors,
                    --    optionsText: 'name',
                    --    optionsValue: 'name'">
                    ]
                    []
                , button
                    [ id "add-armor"
                    , onClick Null

                    -- addArmor; value: selectedArmor">Add</button>
                    ]
                    []
                , li []
                    [--             <label for="auto-sort">Auto-sort</label>
                     --             <input type="checkbox" id="auto-sort" data-bind="checked: autoSort" />
                    ]
                ]
            ]
        ]



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
