var arm = {
	asc: 1,
	desc: -1,
	numericSort: function(l,r,o) {
		var order;
		if (typeof o === "undefined") {order = arm.asc;} else { order = o;}
		return l === r ? 0 : (l > r ? 1 : -1) * order;
	},
	defaultTo: function(prop,def) {
		if (typeof prop === "undefined" || prop === null) {
			return def;
		} else {
			return prop;
		}
	},
	setStorage: function(key, value) {
		if(typeof(Storage) !== "undefined") {
			return localStorage.setItem(key, value);
		} else {
		    console.log("no storage");
		}
	},
	getStorage: function(key) {
		if(typeof(Storage) !== "undefined") {
		    return localStorage.getItem(key);
		} else {
		    console.log("no storage");
		}
	},
	saveCharacter: function(character) {
		arm.setStorage("character", character);
	},
	loadCharacter: function() {
		var storedCharacter = arm.getStorage("character");
		if (storedCharacter === undefined) {
			return [];
		} else {
			return JSON.parse(storedCharacter);
		}
	},
	loadArmors: function() {
		var storedArmors = getStorage("comparedArmors");
	}
};

function Armor(data, character, enhancements) {
	var self = this;
	self.name = data.name;
	self.armor = data.armor;
	self.maxDex = data.maxDex;
	self.checkPenalty = ko.observable(data.checkPenalty);
	self.cost = ko.observable(data.cost);
	self.comfortable = ko.observable(false);
	self.mithral = ko.observable(false);
	self.enhancements = enhancements;
	self.selectedEnhancement = ko.observable(0);
	self.robustSelectedEnhancement = ko.computed(function() {
		var pos = self.enhancements().map(function(i) {return i.bonus;}).indexOf(self.selectedEnhancement());
		return self.enhancements()[pos];
	});
	self.totalMaxDex = ko.computed(function() {
		return self.maxDex + (self.mithral() ? 2 : 0);
	});
	self.totalCost = ko.computed(function() {
		return self.cost() + (self.comfortable() ? 5000 : 0) +
			self.robustSelectedEnhancement().cost +
			(self.mithral() ? 9000 : 0);
	});
	self.totalCheckPenalty = ko.computed(function() {
		return self.checkPenalty() - (self.comfortable() ? -1 : 0) - (self.mithral() ? -3 : 0);
	});
	self.flightBonus = ko.computed(function() {
		return parseInt(self.totalCheckPenalty(), 10) + character.flyingBeforeCheckPenalty();
	});
	self.totalArmor = ko.computed(function() {
		return self.armor + Math.min(self.totalMaxDex(), character.dexMod()) + self.robustSelectedEnhancement().bonus;
	});
}

function Character(characterData) {
	var self = this;
	var data = characterData || {};
    self.dexMod = ko.observable(data.dexMod || 0);
    self.flyingClassSkill = ko.observable(data.flyingClassSkill || false);
    self.flyingRanks = ko.observable(arm.defaultTo(data.flyingRanks,0));
    self.flyingBeforeCheckPenalty = ko.computed(function() {
    	return parseInt(self.dexMod(), 10) +
    		((self.flyingClassSkill() && (parseInt(self.flyingRanks(),10) > 0)) ? 3 : 0) +
    		parseInt(self.flyingRanks(), 10);
    });
}

function CharacterViewModel() {
	var self = this;
	self.character = new Character(arm.loadCharacter());
	self.selectedArmor = ko.observable();
	self.enhancements = ko.observableArray([]);
	var armorData = myget("./data/armor.json");
	self.armors = ko.observableArray([]);
	armorData.then(function(res) { 
		self.armors(JSON.parse(res));
	});
	//TODO - these promises have dependencies that might happen first
	// Also I'm pretty much calling them then immediately blocking...
	var enhancementData = myget("./data/enhancement.json");
	enhancementData.then(function(res) {
		self.enhancements(JSON.parse(res));
	});
	self.comparedArmors = ko.observableArray([]);
	self.addArmor = function() {
		var pos = self.armors().map(function(i) {return i.name;}).indexOf(self.selectedArmor());
		self.comparedArmors.push(new Armor(self.armors()[pos], self.character, self.enhancements));
	};
	self.remove = function(comparedArmor) {
		self.comparedArmors.remove(comparedArmor);
	};
	self.sortedArmors = ko.computed(function() {
		return self.comparedArmors().sort(function(left,right) {
			var byArmor = arm.numericSort(left.totalArmor(), right.totalArmor(), arm.desc);
			var byArmorThenCheckPenalty = byArmor === 0 ? arm.numericSort(left.totalCheckPenalty(),right.totalCheckPenalty(), arm.desc) : byArmor;
			return byArmorThenCheckPenalty === 0 ? arm.numericSort(left.totalCost(),right.totalCost(),arm.asc): byArmorThenCheckPenalty;
		});
	});
	self.persistCharacter = ko.computed(function() {
		arm.saveCharacter(ko.toJSON(self.character));
	});
}

var loadedCharacter = arm.loadCharacter();
var characterViewModel = new CharacterViewModel();
//if (typeof loadedCharacter !== "undefined") {
	//characterViewModel = ko.mapping.fromJS(loadedCharacter, characterViewModel);
//}

ko.applyBindings(characterViewModel);