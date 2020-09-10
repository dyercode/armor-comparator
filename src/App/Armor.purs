module App.Armor where 

import Prelude

type Armor =
  { name :: String
  , armor :: Int
  , maxDex :: Int
  , cost :: Int
  , mithral :: Boolean
  , comfortable :: Boolean
  , checkPenalty :: Int
  }

totalMaxDex :: Armor -> Int
totalMaxDex armor = if armor.mithral
                      then armor.maxDex + 2
                      else armor.maxDex

type Character =
  { dexMod :: Int
  , flyingClassSkill :: Boolean
  , flyingRanks :: Int
  }