import { asc } from '../../output/App.Utils';

export function numericSort(l, r, o) {
    let order;
    if (typeof o === "undefined") { order = asc; } else { order = o; }
    return l === r ? 0 : (l > r ? 1 : -1) * order;
}

export function defaultTo(prop, def) {
    if (typeof prop === "undefined" || prop === null) {
        return def;
    } else {
        return prop;
    }
}
