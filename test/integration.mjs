import { IncrementalMerkleTree } from "@zk-kit/incremental-merkle-tree";
import { poseidon } from "circomlibjs";
import { Contract, ethers, Signer, Wallet } from "ethers";
import { exit } from "process";
import { groth16 } from "snarkjs";

const userPrivKeys = [
    "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
    "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d",
    "0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a",
    "0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
    "0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a",
    ];
const asiPrivKeys = [
    "0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba",
    "0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e",
    "0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356",
    "0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97",
    "0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6",
    ];
//const questions = userPrivKeys.map((key, i) => poseidon(key, i * 10));

const provider = new ethers.providers.JsonRpcProvider(); // local
const userSigners = userPrivKeys.map((key) => new Wallet(key, provider));
const asiSigners = asiPrivKeys.map((key) => new Wallet(key, provider));

const asiContract = new Contract(
    "0x00a9a7162107c8119b03c0ce2c9a2ff7bed70c98",
    [
        "event Register(uint indexed sessionId, uint question, address standIn)",
        "event Proof(uint indexed sessionId, address user)",
        "error SessionDoesNotExistError()",
        "error AlreadyProofedError()",
        "error VerificationError()",
        "function createSession(uint sessionId, uint userTreeRoot) public",
        "function getUserTreeRoot(uint sessionId) public view returns (uint)",
        "function getQuestionTreeRoot(uint sessionId) public view returns (uint)",
        "function register(uint sessionId, uint question) public",
        "function proof(uint sessionId, uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint userIndex) public returns (bool r)",
    ],
    provider
    );


function getTree(leafs) {
    const tree = new IncrementalMerkleTree(poseidon, 5, 0, 2);
    for (const leaf of leafs) {
        tree.insert(BigInt(leaf));
    }
    return tree;
}
const userAddrs = userPrivKeys.map((key) => ethers.utils.computeAddress(key));
const userTree = getTree(userAddrs);
console.log("userTree.root: %d", userTree.root);

const sessionId = Date.now();
console.log("==== sessionId: ", sessionId);
const tx = await asiContract.connect(userSigners[4]).createSession(sessionId, userTree.root);
const receipt = await tx.wait();
console.log("createSession: ", receipt);

// TODO: secret generation
// TODO: random
const secrets = userAddrs.map((addr, i) => i * 10);
const questions = userAddrs.map((addr, i) => poseidon([addr, secrets[i]]));

if ((await asiContract.queryFilter(asiContract.filters.Register(sessionId), 7888888)).length == 0) {
    console.log("============= no events are found, creating...");
    for (let i = 0; i < asiSigners.length; i++) {
        console.log("questions[i]: ", questions[i]);
        const tx = await asiContract.connect(asiSigners[i]).register(sessionId, questions[i]);
        const receipt = await tx.wait();
    }
} else {
    console.log("==== skip creating events...");
}

// TODO: filter by sessionId
// TODO: starting block
const filter = asiContract.filters.Register(sessionId);
const events = await asiContract.queryFilter(filter, 7888888);
console.log("events.length: ", events.length);
const event = events[0];
console.log(event.args.question.toBigInt());
const questionTree = getTree(events.map((e) => e.args.question.toBigInt()));
console.log("questionTree.root: ", questionTree.root);

//for (let i = 0; i < 5; i++) {
//    console.log("storage: ", BigInt(await provider.getStorageAt(asiContract.address, i)));
//}
const userIndex = userTree.indexOf(BigInt(userAddrs[2]));
console.log("userIndex: ", userIndex);
const questionIndex = questionTree.indexOf(BigInt(questions[2]));
console.log("questionIndex: ", questionIndex);

const userMerkleProof = userTree.createProof(userIndex);
console.log("userMerkleProof: ", userMerkleProof);

const questionMerkleProof = questionTree.createProof(questionIndex);
console.log("questionMerkleProof: ", questionMerkleProof);

const secret = secrets[2];

var circuitInput = {
    user: String(userMerkleProof.leaf),
    userPathIndices: userMerkleProof.pathIndices.map(x => String(x)),
    userSiblings: userMerkleProof.siblings.map(x => String(x[0])),

    secret: String(secret),

    questionPathIndices: questionMerkleProof.pathIndices.map(x => String(x)),
    questionSiblings: questionMerkleProof.siblings.map(x => String(x[0])),
};
console.log("circuitInput: ");
console.log("%j", circuitInput);

const { proof, publicSignals } = await groth16.fullProve(circuitInput, "./out/anonymous_stand_in_js/anonymous_stand_in.wasm", "./out/anonymous_stand_in_js/anonymous_stand_in_0001.zkey");
console.log("proof: ");
console.log("%j", proof);
console.log("publicSignals: ");
console.log("%j", publicSignals);

// https://github.com/iden3/snarkjs/blob/a483c5d3b089659964e10531c4f2e22648cf5678/src/groth16_exportsoliditycalldata.js#L37
// beware of the order!
const a = [ proof.pi_a[0], proof.pi_a[1] ];
const b = [[ proof.pi_b[0][1], proof.pi_b[0][0] ],
           [ proof.pi_b[1][1], proof.pi_b[1][0] ]];
const c = [ proof.pi_c[0],  proof.pi_c[1] ];

console.log("proof generated. going to invoke the contract...");

async function logReceipt(f) {
    const tx = await f();
    const recipt = await tx.wait();
    console.log("receipt: ", receipt);
}
//const tx = await asiContract.connect(userSigners[2]).proof(sessionId, a, b, c, BigInt(2));
//const receipt = await tx.wait();
//console.log("receipt: " , receipt);
logReceipt(() => asiContract.connect(userSigners[2]).proof(sessionId, a, b, c, BigInt(2)));
//logReceipt(() => asiContract.connect(userSigners[2]).proof(sessionId, a, b, c, BigInt(2)));