module Calculates exposing
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
    , setEnhancement
    , setMithral
    , sortArmor
    , totalArmor
    , totalCheckPenalty
    , totalMaxDex
    , updateEnhancement
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


getCost : EnchantedArmor -> Int
getCost (EnchantedArmor armor modification) =
    let
        comfortableCost =
            if modification.comfortable then
                5000

            else
                0

        mithralCost =
            if modification.mithral then
                9000

            else
                0
    in
    armor.cost
        + (modification.enhancement * modification.enhancement * 1000)
        + comfortableCost
        + mithralCost


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


setComfortable : Bool -> EnchantedArmor -> EnchantedArmor
setComfortable newComfortable (EnchantedArmor a m) =
    EnchantedArmor a { m | comfortable = newComfortable }


setMithral : Bool -> EnchantedArmor -> EnchantedArmor
setMithral newMithral (EnchantedArmor a m) =
    EnchantedArmor a { m | mithral = newMithral }


setEnhancement : Int -> EnchantedArmor -> EnchantedArmor
setEnhancement newEnhancement (EnchantedArmor a m) =
    EnchantedArmor a { m | enhancement = newEnhancement }


updateEnhancement : (Int -> Int) -> EnchantedArmor -> EnchantedArmor
updateEnhancement f (EnchantedArmor a m) =
    EnchantedArmor a { m | enhancement = f m.enhancement }


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
flyingBeforeCheckPenalty character =
    let
        pointsFromClass =
            if character.flyingClassSkill && character.flyingRanks > 0 then
                3

            else
                0
    in
    character.dexMod + pointsFromClass + character.flyingRanks


flightBonus : EnchantedArmor -> Character r -> Int
flightBonus ea character =
    totalCheckPenalty ea + flyingBeforeCheckPenalty character


sortArmor : List ( EnchantedArmor, a ) -> Character r -> List ( EnchantedArmor, a )
sortArmor eas ch =
    List.sortWith (armorComparison ch) eas


armorComparison : Character r -> ( EnchantedArmor, a ) -> ( EnchantedArmor, a ) -> Order
armorComparison c ( a, _ ) ( b, _ ) =
    let
        armpare =
            descend <| compare (totalArmor a c) (totalArmor b c)

        checkpare =
            descend <| compare (totalCheckPenalty a) (totalCheckPenalty b)

        costpare =
            compare (getCost a) (getCost b)
    in
    armpare |> tyvm checkpare |> tyvm costpare


{-| elvis operator - I don't have a good name for this.
| | if it's equal use the next sorter down the line
-}
tyvm : Order -> Order -> Order
tyvm b a =
    if a == EQ then
        b

    else
        a


descend : Order -> Order
descend a =
    case a of
        LT ->
            GT

        EQ ->
            EQ

        GT ->
            LT
