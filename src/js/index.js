import { Elm } from '../Main.elm'

const crypto = window.crypto || window.msCrypto;

const getRandomInts = (n) => {
    const randInts = new Uint32Array(n);
    crypto.getRandomValues(randInts);
    return Array.from(randInts);
};

// For a UUID, we need at least 128 bits of randomness.
// This means we need to seed our generator with at least 4 32-bit ints.
// We get 5 here, since the Pcg.Extended generator performs slightly faster if our extension array
// has a size that is a power of two (4 here).
const randInts = getRandomInts(5);
const flags = [randInts[0], randInts.slice(1)]

document.addEventListener("DOMContentLoaded", () => {
    Elm.Main.init({
        node: document.getElementById('loadit'),
        flags: flags
    });
});
