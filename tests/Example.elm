module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Main exposing (Armor, EnchantedArmor, Modifications, defaultModifications, plusify, totalMaxDex)
import Test exposing (..)


plusSuite =
    describe "plussify"
        [ test "Prepends the plus sign to a number" <|
            \() -> plusify 1 |> Expect.equal "+1"
        , test "Except when the number is negative" <|
            \() -> plusify -1 |> Expect.equal "-1"
        ]


tmdSuite =
    let
        someArmor : Armor
        someArmor =
            { name = "Full plate"
            , armor = 9
            , maxDex = 1
            , checkPenalty = -6
            , cost = 1500
            }
    in
    describe "totalMaxDex"
        [ fuzz int "is the raw value when not mithral" <|
            \num ->
                totalMaxDex (Main.EnchantedArmor { someArmor | maxDex = num } defaultModifications "2")
                    |> Expect.equal num
        , fuzz int "is inclreased by 2 for mithral" <|
            \num ->
                totalMaxDex (Main.EnchantedArmor { someArmor | maxDex = num } { defaultModifications | mithral = True } "1")
                    |> Expect.equal (num + 2)
        ]
