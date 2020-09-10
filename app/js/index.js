import { enhancementData } from '../static/data/enhancement';
import { armorData } from '../static/data/armor';
import { CharacterViewModel } from './armpare';
import * as ko from 'knockout';

document.addEventListener("DOMContentLoaded", () => {
    const cvm = new CharacterViewModel(armorData, enhancementData);
    ko.applyBindings(cvm);
});
