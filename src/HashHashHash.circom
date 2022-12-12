pragma circom 2.1.0;

include "circomlib/poseidon.circom";
include "circomlib/multiplexer.circom";

template HashHashHash(HASH_COUNT) {
    var ZERO = 0;
    var HASH_INPUT_COUNT = 16;
    var MAX_INPUT_COUNT = HASH_COUNT * (HASH_INPUT_COUNT - 1);
    signal input inputs[MAX_INPUT_COUNT];
    signal input inputCount;
    signal output out;

    component hashes[HASH_COUNT];
    component mux = Multiplexer(1, HASH_COUNT);
    for (var h = 0; h < HASH_COUNT; h++) {
        hashes[h] = Poseidon(HASH_INPUT_COUNT);

        hashes[h].inputs[0] <== h == 0 ? ZERO : hashes[h - 1].out;

        for (var hi = 1; hi < HASH_INPUT_COUNT; hi++) {
            hashes[h].inputs[hi] <== inputs[h * (HASH_INPUT_COUNT - 1) + (hi - 1)];
        }
        mux.inp[h][0] <== hashes[0].out;
    }
    mux.sel <== (inputCount - 1) \ (HASH_INPUT_COUNT - 1);
    out <== mux.out[0];
}

component main = HashHashHash(2);
/*
INPUT =
{"inputs":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29],"inputCount":30}
*/