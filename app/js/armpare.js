import * as ko from 'knockout';
import { defaultTo, numericSort } from './utils';
import { asc, desc, plusify } from '../../output/App.Utils';

function setStorage(key, value) {
	if (typeof (Storage) !== "undefined") {
		return localStorage.setItem(key, value);
	} else {
		console.log("no storage");
	}
}

function getStorage(key) {
	if (typeof (Storage) !== "undefined") {
		return localStorage.getItem(key);
	} else {
		console.log("no storage");
	}
}

export function saveCharacter(character) {
	setStorage("character", character);
}

function saveArmors(armors) {
	setStorage("armors", armors);
}

function loadCharacter() {
	var storedCharacter = getStorage("character");
	if (storedCharacter === undefined) {
		return {};
	} else {
		return JSON.parse(storedCharacter);
	}
}

function loadArmors() {
	let storedArmors = getStorage("armors");
	if (storedArmors === undefined || storedArmors === null) {
		return [];
	} else {
		return JSON.parse(storedArmors);
	}
}

class Armor {
	constructor(data) {
		this.name = data.name;
		this.armor = data.armor;
		this.maxDex = data.maxDex;
		this.checkPenalty = ko.observable(data.checkPenalty);
		this.cost = data.cost;
		this.comfortable = ko.observable(data.comfortable);
		this.mithral = ko.observable(data.mithral);
		this.selectedEnhancement = ko.observable(data.selectedEnhancement || 0);
	}

	robustSelectedEnhancement(enhancements) {
		let pos = enhancements.map((i) => i.bonus).indexOf(this.selectedEnhancement());
		return enhancements[pos];
	}

	totalMaxDex() {
		return this.maxDex + (this.mithral() ? 2 : 0);
	}

	totalCost(enhancements) {
		return this.cost + (this.comfortable() ? 5000 : 0) + this.robustSelectedEnhancement(enhancements).cost + (this.mithral() ? 9000 : 0);
	}

	totalCheckPenalty() {
		return this.checkPenalty() - (this.comfortable() ? -1 : 0) - (this.mithral() ? -3 : 0);
	}

}

class Character {
	constructor(characterData) {
		let data = characterData || {};
		this.dexMod = ko.observable(data.dexMod || 0);
		this.flyingClassSkill = ko.observable(data.flyingClassSkill || false);
		this.flyingRanks = ko.observable(defaultTo(data.flyingRanks, 0));
	}

	get flyingBeforeCheckPenalty() {
		let self = this;
		return ko.computed(() => {
			return parseInt(self.dexMod(), 10) +
				((self.flyingClassSkill() && (parseInt(self.flyingRanks(), 10) > 0)) ? 3 : 0) +
				parseInt(self.flyingRanks(), 10);
		})
	}
}

export class CharacterViewModel {
	constructor(armorData, enhancements) {
		this.character = ko.observable(new Character(loadCharacter()));
		this.selectedArmor = ko.observable();
		this.enhancements = enhancements;
		this.armors = armorData;
		this.comparedArmors = ko.observableArray([]);
		loadArmors().map((a) => {
			this.comparedArmors.push(new Armor(a));
		});
		this.autoSort = ko.observable(true);
	}

	addArmor() {
		let pos = this.armors.map((i) => i.name).indexOf(this.selectedArmor());
		this.comparedArmors.push(new Armor(this.armors[pos]));
	}

	remove(comparedArmor) {
		this.comparedArmors.remove(comparedArmor);
	}

	sortedArmors() {
		let defensiveCopy = this.comparedArmors().concat();
		return defensiveCopy.sort((left, right) => {
			let byArmor = numericSort(this.totalArmorRaw(left, this.character()), this.totalArmorRaw(right, this.character()), desc);
			let byArmorThenCheckPenalty = byArmor === 0 ? numericSort(left.totalCheckPenalty(), right.totalCheckPenalty(), desc) : byArmor;
			return byArmorThenCheckPenalty === 0 ? numericSort(left.totalCost(this.enhancements), right.totalCost(this.enhancements), asc) : byArmorThenCheckPenalty;
		});
	}

	persistCharacter() {
		let self = this;
		return ko.computed(function () {
			saveCharacter(ko.toJSON(self.character));
		});
	}

	persistArmors() {
		let self = this;
		return ko.computed(function () {
			let fields = ["name", "armor", "maxDex", "checkPenalty", "cost", "comfortable", "mithral", "selectedEnhancement"];
			saveArmors(ko.toJSON(self.comparedArmors, fields));
		});
	}

	flightBonus(armor, character) {
		return plusify(parseInt(armor.totalCheckPenalty(), 10) + character.flyingBeforeCheckPenalty());
	}

	totalArmorRaw(armor, character) {
		return plusify(
			armor.armor +
			Math.min(armor.totalMaxDex(), character.dexMod()) +
			armor.robustSelectedEnhancement(this.enhancements).bonus);
	}
}
