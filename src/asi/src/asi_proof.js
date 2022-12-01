import { IncrementalMerkleTree } from "@zk-kit/incremental-merkle-tree";
import { poseidon } from "circomlibjs";
import { groth16 } from "snarkjs";

function getTree(leafs) {
    const tree = new IncrementalMerkleTree(poseidon, 5, 0, 2);
    for (const leaf of leafs) {
        tree.insert(BigInt(leaf));
    }
    return tree;
}

// format = (i) => "0x" + i.toString(16)
function getCircuitInput(userAddr, userAddrs, secret, questions, format = (i) => i) {
    const userTree = getTree(userAddrs);
    const userIndex = userTree.indexOf(BigInt(userAddr));
    const userMerkleProof = userTree.createProof(userIndex);

    const question = poseidon([userAddr, secret]);
    const questionTree = getTree(questions);
    const questionIndex = questionTree.indexOf(BigInt(question));
    const questionMerkleProof = questionTree.createProof(questionIndex);

    const circuitInput = {
        user: format(userMerkleProof.leaf),
        userPathIndices: userMerkleProof.pathIndices.map(x => format(x)),
        userSiblings: userMerkleProof.siblings.map(x => format(x[0])),

        secret: format(secret),

        questionPathIndices: questionMerkleProof.pathIndices.map(x => format(x)),
        questionSiblings: questionMerkleProof.siblings.map(x => format(x[0])),
    };
    return circuitInput;
}

function generateProof(userAddr, userAddrs, secret, questions, wasm, zkey) {
    const circuitInput = getCircuitInput(userAddr, userAddrs, secret, questions);
    return groth16.fullProve(circuitInput, wasm, zkey);
}

export { getTree, getCircuitInput, generateProof };

//const ci = getCircuitInput(3, [0, 1, 2, 3, 4], 42, [2, 5, poseidon([3, 42]), 4]);
//console.log(ci);
//const proof = await generateProof(3, [0, 1, 2, 3, 4], 42, [2, 5, poseidon([3, 42]), 4]);
//console.log("==== proof:");
//console.log(proof);