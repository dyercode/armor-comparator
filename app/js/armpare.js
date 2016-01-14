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
	saveArmors: function(armors) {
		arm.setStorage("armors", armors);
	},
	loadCharacter: function() {
		var storedCharacter = arm.getStorage("character");
		if (storedCharacter === undefined) {
			return {};
		} else {
			return JSON.parse(storedCharacter);
		}
	},
	loadArmors: function() {
		var storedArmors = arm.getStorage("armors");
		if (storedArmors === undefined || storedArmors === null) {
			return [];
		} else {
			return JSON.parse(storedArmors);
		}
	},
	plusify: function(num) {
		return num >= 0 ? '+' + num : num;
	}
};

function Armor(data, character, enhancements) {
	var self = this;
	self.name = data.name;
	self.armor = data.armor;
	self.maxDex = data.maxDex;
	self.checkPenalty = ko.observable(data.checkPenalty);
	self.cost = data.cost;
	self.comfortable = ko.observable(data.comfortable);
	self.mithral = ko.observable(data.mithral);
	self.enhancements = enhancements;
	self.selectedEnhancement = ko.observable(data.selectedEnhancement || 0);
	self.robustSelectedEnhancement = ko.computed(function() {
		var pos = self.enhancements.map(function(i) {return i.bonus;}).indexOf(self.selectedEnhancement());
		return self.enhancements[pos];
	});
	self.totalMaxDex = ko.computed(function() {
		return self.maxDex + (self.mithral() ? 2 : 0);
	});
	self.totalCost = ko.computed(function() {
		return self.cost + (self.comfortable() ? 5000 : 0) +
			self.robustSelectedEnhancement().cost +
			(self.mithral() ? 9000 : 0);
	});
	self.totalCheckPenalty = ko.computed(function() {
		return self.checkPenalty() - (self.comfortable() ? -1 : 0) - (self.mithral() ? -3 : 0);
	});
	self.flightBonus = ko.computed(function() {
		return arm.plusify(parseInt(self.totalCheckPenalty(), 10) + character().flyingBeforeCheckPenalty());
	});
	self.totalArmor = ko.computed(function() {
		return arm.plusify(self.armor + Math.min(self.totalMaxDex(), character().dexMod()) + self.robustSelectedEnhancement().bonus);
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

function CharacterViewModel(armorData, enhancementData) {
	var self = this;
	self.character = ko.observable(new Character(arm.loadCharacter()));
	self.selectedArmor = ko.observable();
	self.enhancements = enhancementData;
	self.armors = armorData;
	self.comparedArmors = ko.observableArray(arm.loadArmors().map(function(a) {
		return new Armor(a,self.character, self.enhancements);
	}));
	self.autoSort = ko.observable(true);
	self.addArmor = function() {
		var pos = self.armors.map(function(i) {return i.name;}).indexOf(self.selectedArmor());
		self.comparedArmors.push(new Armor(self.armors[pos], self.character, self.enhancements));
	};
	self.remove = function(comparedArmor) {
		self.comparedArmors.remove(comparedArmor);
	};
	self.sortedArmors = ko.computed(function() {
		var defensiveCopy = self.comparedArmors().concat();
		return defensiveCopy.sort(function(left,right) {
			var byArmor = arm.numericSort(left.totalArmor(), right.totalArmor(), arm.desc);
			var byArmorThenCheckPenalty = byArmor === 0 ? arm.numericSort(left.totalCheckPenalty(),right.totalCheckPenalty(), arm.desc) : byArmor;
			return byArmorThenCheckPenalty === 0 ? arm.numericSort(left.totalCost(),right.totalCost(),arm.asc): byArmorThenCheckPenalty;
		});
	});
	self.persistCharacter = ko.computed(function() {
		arm.saveCharacter(ko.toJSON(self.character));
	});
	self.persistArmors = ko.computed(function() {
		var fields = ["name", "armor", "maxDex", "checkPenalty", "cost", "comfortable", "mithral", "selectedEnhancement"];
		arm.saveArmors(ko.toJSON(self.comparedArmors, fields));
	});
}

var armorData = myget("./data/armor.json");
var enhancementData = myget("./data/enhancement.json");
Promise.all([armorData,enhancementData]).then(function(args){
	return CharacterViewModel.apply(this, args.map(function(a) {return JSON.parse(a);}));
}).then(ko.applyBindings);
