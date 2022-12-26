"use strict";
import { IncrementalMerkleTree } from "@zk-kit/incremental-merkle-tree";
import { poseidon } from "circomlibjs";

{
const tree = new IncrementalMerkleTree(poseidon, 2, 0, 2);
tree.insert(BigInt(0));
tree.insert(BigInt(1));
tree.insert(BigInt(2));
tree.insert(BigInt(3));
console.log(tree.root);
// 3720616653028013822312861221679392249031832781774563366107458835261883914924n
}

{
const h0 = poseidon([BigInt(0), BigInt(1)]);
const h1 = poseidon([BigInt(2), BigInt(3)]);
const h2 = poseidon([h0, h1]);
console.log(h2);
// 3720616653028013822312861221679392249031832781774563366107458835261883914924n
}

{
const tree = new IncrementalMerkleTree(poseidon, 3, 0, 2);
for (var i = 0; i < 8; i++) {
    tree.insert(BigInt(i));
}
console.log(tree.root);
// 11780650233517635876913804110234352847867393797952240856403268682492028497284n
}
