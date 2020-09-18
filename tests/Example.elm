module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Main exposing (EnchantedArmor, Armor, Modifications, plusify, defaultModifications, totalMaxDex )


plusSuite =
    describe "plussify" 
        [ test "Prepends the plus sign to a number" <|
                \() -> plusify 1 |> Expect.equal "+1"
        , test "Except when the number is negative" <|
            \() -> plusify -1 |> Expect.equal "-1"
        ]

tmdSuite =
    let 
      someArmor = { name = "Full plate",
         armor = 9, maxDex = 1, checkPenalty = -6, cost = 1500 
        }
    in 
    describe "totalMaxDex"
        [ test "is the raw value when not mithral" <| 
            \() -> totalMaxDex (Main.EnchantedArmor someArmor defaultModifications "1") |> Expect.equal someArmor.maxDex

        , test "is inclreased by 2 for mithral" <|
          \() -> (totalMaxDex (Main.EnchantedArmor someArmor ({defaultModifications |  mithral= True })) "1") |> Expect.equal (someArmor.maxDex + 2)
        ]