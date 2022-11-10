import { poseidon } from "circomlibjs" // v0.0.8
import { IncrementalMerkleTree } from "@zk-kit/incremental-merkle-tree"
import * as fs from 'node:fs';
import { argv } from 'process';

//console.log(poseidon([BigInt(1), BigInt(2)]))
//console.log(poseidon([1, 2]))

const item = argv[2];
const listFile = argv[3];
console.log("item: %s listFile: %s", item, listFile);

const tree = new IncrementalMerkleTree(poseidon, 5, BigInt(0), 2) // Binary tree.

const allFileContents = fs.readFileSync(listFile, 'utf-8');
allFileContents.split(/\r?\n/).forEach(line =>  {
    console.log("Line from file: %s", line);
    tree.insert(BigInt(line));
    console.log("tree.root: %d", tree.root);
});

const idx = tree.indexOf(BigInt(item));
console.log("idx: %d", idx);

const proof = tree.createProof(idx);
console.log(proof);

var circuitInput = {
    leaf: String(proof.leaf),
    pathIndices: proof.pathIndices.map(x => String(x)),
    siblings: proof.siblings.map(x => String(x[0]))
};
console.log("%j", circuitInput);
