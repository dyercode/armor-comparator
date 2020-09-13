type character = {
  dexMod: int,
  flyingClassSkill: bool,
  flyingRanks: int,
}

let defaultCharacter = {
  dexMod: 0,
  flyingClassSkill: false,
  flyingRanks: 0,
}

type enhancement = {
  bonus: int,
  cost: int,
}

type armor = {
  armor: int,
  maxDex: int,
  cost: int,
  comfortable: bool,
  mithral: bool,
  selectedEnhancement: enhancement,
}
