module App.Armor where 

type Armor =
  {  name :: String
  , armor :: Int
  , maxDex :: Int
  , cost :: Int
  , mithral :: Boolean
  , comfortable :: Boolean
  , checkPenalty :: Int
  }

type Character =
  { dexMod :: Int
  , flyingClassSkill :: Boolean
  , flyingRanks :: Int
  }