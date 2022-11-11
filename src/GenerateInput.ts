import { poseidon } from "circomlibjs" // v0.0.8
import { IncrementalMerkleTree } from "@zk-kit/incremental-merkle-tree"
import * as fs from 'node:fs';
import { argv } from 'process';

//console.log(poseidon([BigInt(1), BigInt(2)]))
//console.log(poseidon([1, 2]))

function readAllLines(file: string): string[] {
    const allFileContents = fs.readFileSync(file, 'utf-8');
    return allFileContents.split(/\r?\n/).filter(line => line.length > 0);
}

function generateMerkleProof(level: number, item: string, list: string[]) {
    console.log("list length: %d", list.length);
    const tree = new IncrementalMerkleTree(poseidon, level, BigInt(0), 2); // Binary tree.
    list.forEach(x => {
        console.log("List item: %s", x);
        tree.insert(BigInt(x));
        console.log("tree.root: %d", tree.root);
    });

    const idx = tree.indexOf(BigInt(item));
    console.log("idx: %d", idx);

    const proof = tree.createProof(idx);
    console.log(proof);

    return proof;
}

const LEVEL = 5;
const user = argv[2];
const secretFile = argv[3];
const usersFile = argv[4];
const questionsFile = argv[5];
console.log("user: %s secretFile: %s usersFile: %s questionsFile: %s",
    user, secretFile, usersFile, questionsFile);


const userMerkleProof = generateMerkleProof(LEVEL, user, readAllLines(usersFile));

const secret = BigInt(readAllLines(secretFile)[0]);

const question = poseidon([BigInt(user), secret]);
console.log("question: %d", question);

const questionMerkleProof = generateMerkleProof(LEVEL, question, readAllLines(questionsFile));


var circuitInput = {
    user: String(userMerkleProof.leaf),
    userPathIndices: userMerkleProof.pathIndices.map(x => String(x)),
    userSiblings: userMerkleProof.siblings.map(x => String(x[0])),

    secret: String(secret),

    questionPathIndices: questionMerkleProof.pathIndices.map(x => String(x)),
    questionSiblings: questionMerkleProof.siblings.map(x => String(x[0])),
};
console.log("%j", circuitInput);
