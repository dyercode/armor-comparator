const ASC = 1;
const DESC = -1;

function numericSort(l, r, o) {
    let order;
    if (typeof o === "undefined") { order = ASC; } else { order = o; }
    return l === r ? 0 : (l > r ? 1 : -1) * order;
}


export { ASC, DESC, numericSort }