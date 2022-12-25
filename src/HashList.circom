pragma circom 2.1.0;

include "circomlib/poseidon.circom";
include "circomlib/multiplexer.circom";
include "circomlib/comparators.circom";

// choose HASH_INPUT_COUNT = 4 to minimize the average gas cost
template HashList(HASH_COUNT, HASH_INPUT_COUNT) {
    var MAX_INPUT_COUNT = 1 + HASH_COUNT * (HASH_INPUT_COUNT - 1);
    signal input inputs[MAX_INPUT_COUNT]; // the user should fill the trailing slots
    signal input outputHashSelector;
    signal output out;

    component hashes[HASH_COUNT];
    component outputMux = Multiplexer(1, HASH_COUNT);

    for (var h = 0; h < HASH_COUNT; h++) {
        hashes[h] = Poseidon(HASH_INPUT_COUNT);

        hashes[h].inputs[0] <== (h == 0) ? inputs[0] : hashes[h - 1].out;

        for (var hi = 1; hi < HASH_INPUT_COUNT; hi++) {
            hashes[h].inputs[hi] <== inputs[h * (HASH_INPUT_COUNT - 1) + hi];
        }

        outputMux.inp[h][0] <== hashes[h].out;
    }
    outputMux.sel <== outputHashSelector;
    out <== outputMux.out[0];
}

//component main = HashList(6, 4);
/* INPUT = {
"inputs":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18],
"outputHashSelector": 5
} */

/*
4050345352754260300667252706570081029004026400044882557845061748628670512780
3510676252706075353710622977923470633769850687307321002334228238274215327815
12957194406842525945768305445182056040197948786420924760634360581544661385269
3899362167543446351604218567019375731145501307449189070368280709184579142647
14691292887738792867409653573323786688208167038640991871286126213897153851568
748902435937864876241972501117205701882452989848378085868814553847075624288
*/


template ForceTrailingZero(N) {
    assert(N < (1 << 20));    // restrict N to reduce circuit complexity
    signal input inputs[N];
    signal input start;

    component lt[N];
    for (var i = 0; i < N; i++) {
        lt[i] = LessThan(20); // assuming that N < 2^20
        lt[i].in[0] <== i;
        lt[i].in[1] <== start;
        inputs[i] === lt[i].out * inputs[i];
    }
}

// choose HASH_INPUT_COUNT = 4 to minimize the average gas cost
template HashListWithTrailingZero(HASH_COUNT, HASH_INPUT_COUNT) {
    var MAX_INPUT_COUNT = 1 + HASH_COUNT * (HASH_INPUT_COUNT - 1);
    signal input inputs[MAX_INPUT_COUNT];
    signal input length;
    signal input outputHashSelector; // TODO: derive from length
    signal output out;

    component forceTrailingZero = ForceTrailingZero(MAX_INPUT_COUNT);
    component hashList = HashList(HASH_COUNT, HASH_INPUT_COUNT);
    for (var i = 0; i < MAX_INPUT_COUNT; i++) {
        forceTrailingZero.inputs[i] <== inputs[i];
        hashList.inputs[i] <== inputs[i];
    }
    forceTrailingZero.start <== length;
    hashList.outputHashSelector <== outputHashSelector;
    out <== hashList.out;
}

component main = HashListWithTrailingZero(6, 4);
/*
INPUT=
{
"inputs":[0,1,2,3,4,5,6,7,0,0,0,0,0,0,0,0,0,0,0],
"length": "8",
"outputHashSelector": "2"
}
*/