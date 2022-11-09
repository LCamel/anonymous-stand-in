import { poseidon } from "circomlibjs" // v0.0.8
import { IncrementalMerkleTree } from "@zk-kit/incremental-merkle-tree"

//console.log(poseidon([BigInt(1), BigInt(2)]))
//console.log(poseidon([1, 2]))

const tree = new IncrementalMerkleTree(poseidon, 5, BigInt(0), 2) // Binary tree.
tree.insert(BigInt(1));
tree.insert(BigInt(2));
tree.insert(BigInt(3));
console.log("tree.root: %d", tree.root);

const idx = tree.indexOf(BigInt(3));
console.log("idx: %d", idx);

const proof = tree.createProof(idx);
console.log(proof);
