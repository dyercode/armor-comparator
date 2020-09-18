module Calculates exposing (..)


type EnchantedArmor
    = EnchantedArmor Armor Modifications


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
