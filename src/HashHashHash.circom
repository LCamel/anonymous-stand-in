pragma circom 2.1.0;

include "circomlib/poseidon.circom";

template HashHashHash(nHashes) {
    var ZERO = 0;
    var N_HASH_INPUTS = 16;
    var nInputs = nHashes * (N_HASH_INPUTS - 1);
    //var nHashes = ((nInputs - 1) \ (N_HASH_INPUTS - 1)) + 1;
    log("nInputs", nInputs);
    log("nHashes", nHashes);
    signal input inputs[nInputs];
    signal output outputs[nHashes];

    component hashes[nHashes];
    for (var h = 0; h < nHashes; h++) {
        hashes[h] = Poseidon(N_HASH_INPUTS);

        hashes[h].inputs[0] <== h > 0 ? hashes[h - 1].out : ZERO;

        for (var hi = 1; hi < N_HASH_INPUTS; hi++) {
            var i = h * (N_HASH_INPUTS - 1) + (hi - 1);
            hashes[h].inputs[hi] <== i < nInputs ? inputs[i] : ZERO;
        }

        outputs[h] <== hashes[h].out;
    }
}

component main = HashHashHash(6);

