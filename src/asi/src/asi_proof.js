import { IncrementalMerkleTree } from "@zk-kit/incremental-merkle-tree";
import { poseidon } from "circomlibjs";
import { groth16 } from "snarkjs";

class Proof {
static getTree(leafs) {
    const tree = new IncrementalMerkleTree(poseidon, 5, 0, 2);
    for (const leaf of leafs) {
        tree.insert(BigInt(leaf));
    }
    return tree;
}

// format = (i) => "0x" + i.toString(16)
static getCircuitInput(userAddr, userAddrs, secret, questions, format = (i) => i) {
    const userTree = Proof.getTree(userAddrs);
    const userIndex = userTree.indexOf(BigInt(userAddr));
    const userMerkleProof = userTree.createProof(userIndex);

    const question = poseidon([userAddr, secret]);
    const questionTree = Proof.getTree(questions);
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

static generateProof(userAddr, userAddrs, secret, questions, wasm, zkey) {
    const circuitInput = Proof.getCircuitInput(userAddr, userAddrs, secret, questions);
    return groth16.fullProve(circuitInput, wasm, zkey);
}
}
export { Proof };

//const ci = getCircuitInput(3, [0, 1, 2, 3, 4], 42, [2, 5, poseidon([3, 42]), 4]);
//console.log(ci);
//const proof = await generateProof(3, [0, 1, 2, 3, 4], 42, [2, 5, poseidon([3, 42]), 4]);
//console.log("==== proof:");
//console.log(proof);