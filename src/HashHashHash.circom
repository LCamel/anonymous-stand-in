pragma circom 2.1.0;

include "circomlib/poseidon.circom";

template HashHashHash(HASH_COUNT) {
    var INIT = 0;
    var HASH_INPUT_COUNT = 16;
    var MAX_INPUT_COUNT = HASH_COUNT * (HASH_INPUT_COUNT - 1);
    signal input inputs[MAX_INPUT_COUNT]; // the user should fill the trailing slots
    signal input selector[HASH_COUNT];    // [0, 0, 0, 1, 0, 0, ...]
    signal output out;

    component hashes[HASH_COUNT];
    signal selectedOutputSum[HASH_COUNT];
    for (var h = 0; h < HASH_COUNT; h++) {
        hashes[h] = Poseidon(HASH_INPUT_COUNT);

        hashes[h].inputs[0] <== (h == 0) ? INIT : hashes[h - 1].out;

        for (var hi = 1; hi < HASH_INPUT_COUNT; hi++) {
            hashes[h].inputs[hi] <== inputs[h * (HASH_INPUT_COUNT - 1) + (hi - 1)];
        }

        selectedOutputSum[h] <== hashes[h].out * selector[h] + (h == 0 ? 0 : selectedOutputSum[h - 1]);
    }
    out <== selectedOutputSum[HASH_COUNT - 1];
}

component main = HashHashHash(6);
/* INPUT = {"inputs":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89],
"selector": [0, 0, 0, 0, 0, 1]
} */