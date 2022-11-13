pragma circom 2.1.0;

include "circomlib/poseidon.circom";
include "circomlib/mux1.circom";
include "circomlib/bitify.circom";
/* INPUT =
{"user":"124600769394618761707529974069218112888608942693","userPathIndices":["0","0","1","0","0"],"userSiblings":["0","14744269619966411208579211824598458697587494354926760081771325075741142829156","1903336837694064162031105257117176842042144176356952415994091550667815756145","11286972368698509976183087595462810875513684078608517520839298933882497716792","3607627140608796879659380071776844901612302623152076817094415224584923813162"],"secret":"3405691582","questionPathIndices":["1","0","0","0","0"],"questionSiblings":["123","13101852731087686565481713628481620697709655517747549254018203699193810735763","7423237065226347324353380772367382631490014989348495481811164164159255474657","11286972368698509976183087595462810875513684078608517520839298933882497716792","3607627140608796879659380071776844901612302623152076817094415224584923813162"]}
*/

// copied from https://github.com/semaphore-protocol/semaphore/blob/main/packages/circuits/tree.circom
// i don't know how to include it in zkrepl.dev
template MerkleTreeInclusionProof(nLevels) {
    signal input leaf;
    signal input pathIndices[nLevels];
    signal input siblings[nLevels];

    signal output root;

    component poseidons[nLevels];
    component mux[nLevels];

    signal hashes[nLevels + 1];
    hashes[0] <== leaf;

    for (var i = 0; i < nLevels; i++) {
        pathIndices[i] * (1 - pathIndices[i]) === 0;

        poseidons[i] = Poseidon(2);
        mux[i] = MultiMux1(2);

        mux[i].c[0][0] <== hashes[i];
        mux[i].c[0][1] <== siblings[i];

        mux[i].c[1][0] <== siblings[i];
        mux[i].c[1][1] <== hashes[i];

        mux[i].s <== pathIndices[i];

        poseidons[i].inputs[0] <== mux[i].out[0];
        poseidons[i].inputs[1] <== mux[i].out[1];

        hashes[i + 1] <== poseidons[i].out;
    }

    root <== hashes[nLevels];
}

template AnonymousStandIn(nLevels) {
    signal input user;
    signal input userPathIndices[nLevels];
    signal input userSiblings[nLevels];

    signal input secret;

    signal input questionPathIndices[nLevels];
    signal input questionSiblings[nLevels];


    signal output usersRoot;
    signal output userIndex;
    signal output questionsRoot;


    // The user belongs to the list
    component users = MerkleTreeInclusionProof(nLevels);
    users.leaf <== user;
    for (var i = 0; i < nLevels; i++) {
        users.pathIndices[i] <== userPathIndices[i];
        users.siblings[i] <== userSiblings[i];
    }
    usersRoot <== users.root;
    // with index "userIndex".
    component bits2Num = Bits2Num(nLevels);
    for (var i = 0; i < nLevels; i++) {
        bits2Num.in[i] <== userPathIndices[i];
    }
    userIndex <== bits2Num.out;

    // The user knows the answer of a question.
    component hash = Poseidon(2);
    hash.inputs[0] <== user;
    hash.inputs[1] <== secret;
    signal question <== hash.out;

    // The question belongs to the list.
    component questions = MerkleTreeInclusionProof(nLevels);
    questions.leaf <== question;
    for (var i = 0; i < nLevels; i++) {
        questions.pathIndices[i] <== questionPathIndices[i];
        questions.siblings[i] <== questionSiblings[i];
    }
    questionsRoot <== questions.root;
}

component main { public [user] } = AnonymousStandIn(5);
