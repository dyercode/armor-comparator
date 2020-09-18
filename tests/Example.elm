module Example exposing (..)

import Calculates exposing (Armor, Character, EnchantedArmor(..), Modifications, flyingBeforeCheckPenalty, totalArmor, totalMaxDex)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, bool, int, intRange, list, string)
import Main exposing (plusify)
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
        someArmor =
            { name = "Full plate"
            , armor = 9
            , maxDex = 1
            , checkPenalty = -6
            , cost = 1500
            }

        mod : Modifications
        mod =
            { enhancement = 0
            , mithral = False
            , comfortable = False
            }
    in
    describe "totalMaxDex"
        [ fuzz int "is the raw value when not mithral" <|
            \num ->
                totalMaxDex (EnchantedArmor { someArmor | maxDex = num } mod)
                    |> Expect.equal num
        , fuzz int "is inclreased by 2 for mithral" <|
            \num ->
                totalMaxDex (EnchantedArmor { someArmor | maxDex = num } { mod | mithral = True })
                    |> Expect.equal (num + 2)
        ]


fbcpSuite =
    let
        character =
            { dexMod = 0
            , flyingClassSkill = False
            , flyingRanks = 0
            }
    in
    describe "flyingBeforeCheckPenalty"
        [ fuzz2 int int "is dexMod + points " <|
            \ranks dex ->
                flyingBeforeCheckPenalty { character | flyingRanks = ranks, dexMod = dex }
                    |> Expect.equal (ranks + dex)
        , fuzz2 (intRange 1 100) int "is dexMod + points + bonus if ranks and class skill" <|
            \ranks dex ->
                flyingBeforeCheckPenalty { character | flyingRanks = ranks, dexMod = dex, flyingClassSkill = True }
                    |> Expect.equal (ranks + dex + 3)
        , fuzz2 bool int "is just dexMod when no points in skill regardless of class skill" <|
            \isClass dex ->
                flyingBeforeCheckPenalty { character | dexMod = dex, flyingClassSkill = isClass }
                    |> Expect.equal dex
        ]


taSuite =
    let
        character =
            { dexMod = 0
            , flyingClassSkill = False
            , flyingRanks = 0
            }

        someArmor : Armor
        someArmor =
            { name = "Full plate"
            , armor = 9
            , maxDex = 1
            , checkPenalty = -6
            , cost = 1500
            }

        mod : Modifications
        mod =
            { enhancement = 0
            , mithral = False
            , comfortable = False
            }
    in
    describe "totalArmor"
        [ test "sum of armor and dex and enhancementbonus" <|
            \() ->
                totalArmor (EnchantedArmor someArmor { mod | enhancement = 1 }) { character | dexMod = 1 }
                    |> Expect.equal 11
        , todo "dexMod is capped by maxdex"
        ]
