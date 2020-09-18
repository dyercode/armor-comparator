module Calculates exposing
    ( Armor
    , Character
    , EnchantedArmor(..)
    , Modifications
    , flyingBeforeCheckPenalty
    , getName
    , isComfortable
    , isMithral
    , totalArmor
    , totalCheckPenalty
    , totalMaxDex
    )

import List exposing (map)


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


getName : EnchantedArmor -> String
getName (EnchantedArmor a _) =
    a.name


getArmor : EnchantedArmor -> Int
getArmor (EnchantedArmor a _) =
    a.armor


getMaxDex : EnchantedArmor -> Int
getMaxDex (EnchantedArmor a _) =
    a.maxDex


getCheckPenalty : EnchantedArmor -> Int
getCheckPenalty (EnchantedArmor a _) =
    a.checkPenalty


isMithral : EnchantedArmor -> Bool
isMithral (EnchantedArmor _ m) =
    m.mithral


isComfortable : EnchantedArmor -> Bool
isComfortable (EnchantedArmor _ m) =
    m.comfortable


getEnhancement : EnchantedArmor -> Int
getEnhancement (EnchantedArmor _ m) =
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
