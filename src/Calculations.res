let totalCheckPenalty = (armor: Model.armor) => {
  armor.checkPenalty - (armor.comfortable ? -1 : 0) - (armor.mithral ? -3 : 0)
}

let totalMaxDex = (armor: Model.armor) => {
  armor.maxDex + (armor.mithral ? 2 : 0)
}

let robustSelectedEnhancement = (
  enhancements: array<Model.enhancement>,
  armor: Model.armor,
): option<Model.enhancement> => {
  // let bonuses = Js.Array.map((i: Model.enhancement) => i.bonus, enhancements)
  let selected = Js.Array.find(
    (e: Model.enhancement) => e.bonus == armor.selectedEnhancement,
    enhancements,
  )
  selected
}

let totalCost = (armor: Model.armor, enhancements: array<Model.enhancement>) => {
  let enhanceCost: int = switch robustSelectedEnhancement(enhancements, armor) {
  | Some(e: Model.enhancement) => e.cost
  | None => 0
  }
  armor.cost + (armor.comfortable ? 5000 : 0) + enhanceCost + (armor.mithral ? 9000 : 0)
}

let totalArmor = (armor: Model.armor, character: Model.character, enhancements) => {
  let enhancementBonus = switch robustSelectedEnhancement(enhancements, armor) {
  | Some(b) => b.bonus
  | None => 0
  }

  armor.armor + enhancementBonus + min(totalMaxDex(armor), character.dexMod)
}

let sortArmors = (
  armors: array<Model.armor>,
  character: Model.character,
  enhancements: array<Model.enhancement>,
) => {
  Js.Array.sortInPlaceWith((left, right) => {
    let byArmor = Demo.numericSort(
      totalArmor(left, character, enhancements),
      totalArmor(right, character, enhancements),
      Demo.Descending,
    )
    let byArmorThenCheckPenalty =
      byArmor === 0
        ? Demo.numericSort(totalCheckPenalty(left), totalCheckPenalty(right), Demo.Descending)
        : byArmor
    byArmorThenCheckPenalty === 0
      ? Demo.numericSort(
          totalCost(left, enhancements),
          totalCost(right, enhancements),
          Demo.Ascending,
        )
      : byArmorThenCheckPenalty
  }, armors)
}

let flyingBeforeCheckPenalty = (character: Model.character) => {
  character.dexMod +
  (character.flyingClassSkill && character.flyingRanks > 0 ? 3 : 0) +
  character.flyingRanks
}
// get flyingBeforeCheckPenalty() {
// let self = this;
// return ko.computed(() => {
// return parseInt(self.dexMod(), 10) +
// ((self.flyingClassSkill() && (parseInt(self.flyingRanks(), 10) > 0)) ? 3 : 0) +
// parseInt(self.flyingRanks(), 10);
