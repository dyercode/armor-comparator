import * as ko from 'knockout';
import { plusify, numericSort } from '../../src/Demo.bs'
import { defaultCharacter } from '../../src/Model.bs'
import { loadCharacter, loadArmors, asc, desc } from '../../src/Persistence.bs'
import { totalArmor, totalMaxDex, totalCheckPenalty, flyingBeforeCheckPenalty } from '../../src/Calculations.bs'

function setStorage(key, value) {
	if (typeof (Storage) !== "undefined") {
		return localStorage.setItem(key, value);
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

function sortArmors(armors, character, enhancements) {
	return armors.sort((left, right) => {
		let byArmor = numericSort(totalArmor(left, character, enhancements), totalArmor(right, character, enhancements), desc);
		let byArmorThenCheckPenalty = byArmor === 0 ? numericSort(totalCheckPenalty(left), totalCheckPenalty(right), desc) : byArmor;
		return byArmorThenCheckPenalty === 0 ? numericSort(left.totalCost(enhancements), right.totalCost(enhancements), asc) : byArmorThenCheckPenalty;
	});
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
		totalMaxDex(this);
	}

	totalCost(enhancements) {
		return this.cost + (this.comfortable() ? 5000 : 0) + this.robustSelectedEnhancement(enhancements).cost + (this.mithral() ? 9000 : 0);
	}

	totalCheckPenalty() {
		return this.checkPenalty() - (this.comfortable() ? -1 : 0) - (this.mithral() ? -3 : 0);
	}

}

export class CharacterViewModel {
	constructor(armorData, enhancements) {
		this.character = ko.observable({
			...defaultCharacter,
			...loadCharacter()
		});
		this.selectedArmor = ko.observable();
		this.enhancements = enhancements;
		this.armors = armorData;
		this.comparedArmors = ko.observableArray([]);
		loadArmors().map((a) => { console.dir(a); return new Armor(a) }).map(this.comparedArmors.push);
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
		return sortArmors(defensiveCopy, this.character(), this.enhancements);
	}

	persistCharacter() {
		let self = this;
		return ko.computed(function () {
			saveCharacter(ko.toJSON(self.character));
		});
	}

	persistArmors() {
		let self = this;
		return ko.computed(() => {
			let fields = ["name", "armor", "maxDex", "checkPenalty", "cost", "comfortable", "mithral", "selectedEnhancement"];
			saveArmors(ko.toJSON(self.comparedArmors, fields));
		});
	}

	flightBonus(armor, character) {
		return plusify(totalCheckPenalty(armor) + flyingBeforeCheckPenalty(this.character()));
	}

	totalArmorRaw = totalArmor
}
