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

/*
 	this.armor = data.armor;
 	this.maxDe
 	this.checkPenalty = ko.observable(data.checkPenalty);
 	this.cost = data.cost;
 	this.comfortable = ko.observable(data.comfortable);
 	this.mithral = ko.observable(data.mithral);
 	this.selectedEnhancement = ko.observable(data.selectedEnhancement || 0);
 }
 */
