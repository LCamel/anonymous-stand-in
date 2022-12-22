pragma circom 2.1.0;

include "circomlib/poseidon.circom";
include "circomlib/multiplexer.circom";

template HashList(HASH_COUNT) {
    var HASH_INPUT_COUNT = 6;
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

component main = HashList(6);
/* INPUT = {"inputs":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30],
"outputHashSelector": 5
} */