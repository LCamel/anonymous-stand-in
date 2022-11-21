import { IncrementalMerkleTree } from "@zk-kit/incremental-merkle-tree";
import { poseidon } from "circomlibjs";
import { Contract, ethers, Signer, Wallet } from "ethers";
import { wtns, groth16 } from "snarkjs";
import * as fs from "fs";
import * as cp from "child_process";


console.log("wtns: " , wtns);
console.log("groth16: " , groth16);
console.log(poseidon([1, 2]));

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
        "event Register(address standIn, uint question)",
        "event Proof(address user)",
        "error AlreadyProofedError()",
        "error VerificationError()",
        "function createSession(uint userTreeRoot) public",
        "function register(uint question) public",
        "function proof(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint userIndex) public returns (bool r)",
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

asiContract.connect(userSigners[4]).createSession(userTree.root);

// TODO: secret generation
// TODO: random
const secrets = userAddrs.map((addr, i) => i * 10);
const questions = userAddrs.map((addr, i) => poseidon([addr, secrets[i]]));

if ((await asiContract.queryFilter(asiContract.filters.Register(), 7888888)).length == 0) {
    console.log("============= no events are found, creating...");
    for (let i = 0; i < asiSigners.length; i++) {
        console.log("questions[i]: ", questions[i]);
        const tx = await asiContract.connect(asiSigners[i]).register(questions[i]);
        const receipt = await tx.wait();
    }
} else {
    console.log("==== skip creating events...");
}


const filter = asiContract.filters.Register();
const events = await asiContract.queryFilter(filter, 7888888);
console.log("events.length: ", events.length);
const event = events[0];
console.log(event.args.question.toBigInt());
const questionTree = getTree(events.map((e) => e.args.question.toBigInt()));
console.log("questionTree.root: ", questionTree.root);

for (let i = 0; i < 5; i++) {
    console.log("storage: ", BigInt(await provider.getStorageAt(asiContract.address, i)));
}
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
fs.writeFileSync("./out/input.json", JSON.stringify(circuitInput));
console.log("done");

console.log("going to invoke ./pv.sh");
cp.execFileSync("./pv.sh");
console.log("1111111");
//const proof = JSON.parse(fs.readFileSync("./out/anonymous_stand_in_js/proof.json"));
const proof = JSON.parse("[" + fs.readFileSync("./out/anonymous_stand_in_js/call_remix.txt") + "]");
const a = proof[0];
const b = proof[1];
const c = proof[2];
//console.log("proof: %j", proof);


//const conv = (s) => "0x" + BigInt(s).toString(16);
/*
const conv = (s) => s;
const a = [ conv(proof.pi_a[0]), conv(proof.pi_a[1]) ];
const b = [[ conv(proof.pi_b[0][0]), conv(proof.pi_b[0][1]) ],
           [ conv(proof.pi_b[1][0]), conv(proof.pi_b[1][1]) ]];
const c = [ conv(proof.pi_c[0]), conv(proof.pi_c[1]) ];
*/

//await wtns.calculate(circuitInput, "./out/anonymous_stand_in_js/anonymous_stand_in.wasm", "./out/foo");

//const proofAndPublic = await groth16.prove("./out/anonymous_stand_in_js/anonymous_stand_in_0001.zkey", "./out/foo");
/*
const proofAndPublic = await groth16.fullProve(circuitInput, "./out/anonymous_stand_in_js/anonymous_stand_in.wasm", "./out/anonymous_stand_in_js/anonymous_stand_in_0001.zkey");
console.log("proof and public: ");
console.log("%j", proofAndPublic);
console.log("proof: ");
console.log("%j", proofAndPublic.proof);
console.log("public: ");
console.log("%j", proofAndPublic.publicSignals);

const conv = (s) => "0x" + BigInt(s).toString(16);
const a = [ conv(proofAndPublic.proof.pi_a[0]), conv(proofAndPublic.proof.pi_a[1]) ];
const b = [[ conv(proofAndPublic.proof.pi_b[0][0]), conv(proofAndPublic.proof.pi_b[0][1]) ],
           [ conv(proofAndPublic.proof.pi_b[1][0]), conv(proofAndPublic.proof.pi_b[1][1]) ]];
const c = [ conv(proofAndPublic.proof.pi_c[0]), conv(proofAndPublic.proof.pi_c[1]) ];
*/
/*
const a = [
    BigInt("0x1697a4c6035008c90dcaa170978153c55b7fcfe908460fab39801722f724f864"),
    BigInt("0x06d1283b2739c0fd150189be13eb2c4e9b19d541ba663ac27a47827a886550a2")];
const b = [
    [BigInt("0x04745857281d961da592cf0e674bd720bfce15bdf256e06c821bafd11f16bd50"),
     BigInt("0x102becf10a760dcb8835135f133471a20d66f5036c48e2a23a420694c2046e99")],
    [BigInt("0x14293ad88aba0af2a363463e20ec918047a7c8c8d2e6e8b95d420d8443ca048f"),
     BigInt("0x1ac410005d2fa73324ff1505b0a7af611a7d314f7a81230c4594c3b4f19f60f5")]
    ];
const c = [
    BigInt("0x1a0b5d2e14612a5c7042a054e80e987f1f5e9550ad333a57dae73aab1843fae5"),
    BigInt("0x1743824d017452e293f014821a4939780b64cdb82394d3d84a8b57661aeb4da7")];
*/

/*
// this is copy/paste from the output of snarkjs
// this is a good one
const a = ["0x0115f6693e84fce3adcae9c5581b5b5d7f42cee2ed3c08ba6ab54f6c9e60e60c", "0x220a65f2e0a56951e8e7f900602353f260b097b4892a2dc18564e7edf4887012"];
const b = [["0x25e4d9c326a939165434d6f47c0e1a0f8e9f7efe9ab2cea6519fe190a800307a", "0x2c0974e1331d7e270eaf96ad37136b6b857c8b9be42d739d7c3b9f1f73c4ff7c"],["0x11ad496b1e2720bc385ebce52a6b5e6e8819b66c96a3a3eef9a79a7b3bf0daa4", "0x02dbfc70a05a720f1d848c497188cb97e2588a21f053c9ee6f99db823384d33f"]];
const c = ["0x0a611d8d664d043027d1af93500b182bbc5ba4232c7ef56337ea72b98b733488", "0x2726f7b1192f1d7fdf4dcade6bffc5402e15033a8ad3b24ea60508d51bcc667a"];
*/
console.log("bye");


const tx = await asiContract.connect(userSigners[2]).proof(a, b, c, BigInt(2));
const receipt = await tx.wait();
console.log("receipt: " , receipt);
