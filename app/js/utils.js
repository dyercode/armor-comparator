const ASC = 1;
const DESC = -1;

function numericSort(l, r, o) {
    let order;
    if (typeof o === "undefined") { order = ASC; } else { order = o; }
    return l === r ? 0 : (l > r ? 1 : -1) * order;
}

function defaultTo(prop, def) {
    if (typeof prop === "undefined" || prop === null) {
        return def;
    } else {
        return prop;
    }
}

function plusify(num) {
    return num >= 0 ? '+' + num : num;
}


export { ASC, DESC, numericSort, defaultTo, plusify }