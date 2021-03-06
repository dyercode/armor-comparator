module Example exposing (..)

import Calculates exposing (Armor, EnchantedArmor(..), Modifications, flyingBeforeCheckPenalty, sortArmor, totalArmor, totalMaxDex)
import Expect
import Fuzz exposing (bool, int, intRange)
import Main exposing (plusify)
import Random exposing (maxInt)
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
        , fuzz2 int (intRange 0 maxInt) "dexMod is capped by maxdex" <|
            \dexMod maxDex ->
                totalArmor (EnchantedArmor { someArmor | maxDex = maxDex, armor = 0 } mod) { character | dexMod = dexMod + maxDex }
                    |> Expect.atMost maxDex
        ]


sortSuite =
    let
        character =
            { dexMod = 0
            , flyingClassSkill = False
            , flyingRanks = 0
            }

        someArmor : Armor
        someArmor =
            { name = "bare"
            , armor = 0
            , maxDex = 0
            , checkPenalty = 0
            , cost = 0
            }

        mod : Modifications
        mod =
            { enhancement = 0
            , mithral = False
            , comfortable = False
            }
    in
    describe "should sort right"
        [ test "highest armor first" <|
            \() ->
                character
                    |> sortArmor [ ( EnchantedArmor someArmor mod, "1" ), ( EnchantedArmor { someArmor | armor = 1 } mod, "2" ) ]
                    |> Expect.equalLists [ ( EnchantedArmor { someArmor | armor = 1 } mod, "2" ), ( EnchantedArmor someArmor mod, "1" ) ]
        , test "then lower check penalty" <|
            \() ->
                character
                    |> sortArmor [ ( EnchantedArmor { someArmor | checkPenalty = -1 } mod, "1" ), ( EnchantedArmor someArmor mod, "2" ) ]
                    |> Expect.equalLists [ ( EnchantedArmor someArmor mod, "2" ), ( EnchantedArmor { someArmor | checkPenalty = -1 } mod, "1" ) ]
        , test "then lower cost" <|
            \() ->
                character
                    |> sortArmor [ ( EnchantedArmor { someArmor | cost = 1 } mod, "1" ), ( EnchantedArmor someArmor mod, "2" ) ]
                    |> Expect.equalLists [ ( EnchantedArmor someArmor mod, "2" ), ( EnchantedArmor { someArmor | cost = 1 } mod, "1" ) ]
        ]
