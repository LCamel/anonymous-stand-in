"use strict";
import { poseidon } from "circomlibjs";

const HASH_COUNT = 6;
const HASH_INPUT_COUNT = 4;
const MAX_INPUT_COUNT = 1 + HASH_COUNT * (HASH_INPUT_COUNT - 1);

var inputs = new Array(MAX_INPUT_COUNT);
for (let i = 0; i < inputs.length; i++) {
    inputs[i] = BigInt(i);
}

var outs = new Array(HASH_COUNT);
for (let h = 0; h < HASH_COUNT; h++) {
    const i0 = (h == 0) ? inputs[0] : outs[h - 1];
    const start = 1 + (HASH_INPUT_COUNT - 1) * h;
    outs[h] = poseidon([i0, ...inputs.slice(start, start + (HASH_INPUT_COUNT - 1))]);
    console.log(outs[h]);
}

console.log("==========");

/*
var h = new Array(HASH_COUNT);
h[0] = poseidon([0, 1, 2, 3]);
console.log(h[0]);
h[1] = poseidon([h[0], 4, 5, 6]);
console.log(h[1]);
h[2] = poseidon([h[1], 7, 8, 9]);
console.log(h[2]);
h[3] = poseidon([h[2], 10, 11, 12]);
console.log(h[3]);
h[4] = poseidon([h[3], 13, 14, 15]);
console.log(h[4]);
h[5] = poseidon([h[4], 16, 17, 18]);
console.log(h[5]);
*/

var h = new Array(HASH_COUNT);
h[0] = poseidon([0, 1, 2, 3]);
console.log(h[0]);
h[1] = poseidon([h[0], 4, 5, 6]);
console.log(h[1]);
h[2] = poseidon([h[1], 7, 0, 0]);
console.log(h[2]);
h[3] = poseidon([h[2], 0, 0, 0]);
console.log(h[3]);
h[4] = poseidon([h[3], 0, 0, 0]);
console.log(h[4]);
h[5] = poseidon([h[4], 0, 0, 0]);
console.log(h[5]);
