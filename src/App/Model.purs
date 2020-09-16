
module App.Model where

import Prelude

type Character
  = { name :: String
    , dexMod :: Int
    , flyingClassSkill :: Boolean
    , flyingRanks :: Int
    }

type Armor =
  { name :: String
  , armor :: Int
  , maxDex :: Int
  , cost :: Int
  , mithral :: Boolean
  , comfortable :: Boolean
  , checkPenalty :: Int
  }
