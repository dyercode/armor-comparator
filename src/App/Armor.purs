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

totalCheckPenalty :: Armor -> Int
totalCheckPenalty {checkPenalty : x, mithral: false, comfortable: false} = x
totalCheckPenalty {checkPenalty : x, mithral: true, comfortable: false} = x - 3
totalCheckPenalty {checkPenalty : x, mithral: false, comfortable: true} = x - 1
totalCheckPenalty {checkPenalty : x, mithral: true, comfortable: true} = x - 4

type Character =
  { dexMod :: Int
  , flyingClassSkill :: Boolean
  , flyingRanks :: Int
  }