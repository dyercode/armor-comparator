import * as ko from 'knockout';
import { enhancementData } from '../static/data/enhancement';
import { armorData } from '../static/data/armor';
import { CharacterViewModel } from './armpare';
import { main } from '../../output/Main/index.js';
main();

document.addEventListener("DOMContentLoaded", () => {
    const cvm = new CharacterViewModel(armorData, enhancementData);
    ko.applyBindings(cvm);
});