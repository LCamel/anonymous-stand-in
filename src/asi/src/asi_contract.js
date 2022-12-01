import { poseidon } from "circomlibjs";
import { ethers, Wallet } from "ethers";

// https://docs.alchemy.com/docs/deep-dive-into-eth_getlogs

// returns a promise of events
function getRegisterEvents(provider, asiAddress, fromBlockOrBlockHash, sessionId) {
    const asiAbi = [
        "event Register(uint indexed sessionId, uint question, address standIn)"
    ];
    const asiContract = new ethers.Contract(asiAddress, asiAbi, provider);
    const filter = asiContract.filters.Register(sessionId);
    return asiContract.queryFilter(filter, fromBlockOrBlockHash);
}

function extractQuestions(registerEvents) {
    return registerEvents.map((event) => event.args.question.toBigInt());
}

// Promise: keccak256 of signed sessionId
function getOpinionatedSecret(signer, sessionId) {
    return signer.signMessage(BigInt(sessionId).toString())
        .then(s => BigInt(ethers.utils.keccak256(ethers.utils.toUtf8Bytes(s))));
}
function getQuestion(userAddr, secret) {
    return poseidon([userAddr, secret]);
}
function blah222(a, b) {
    console.log(getQuestion);
    console.log(extractQuestions);
}

export { blah222, getQuestion, getRegisterEvents, extractQuestions, getOpinionatedSecret};




/*
const ASI_ADDRESS = "0x00a9a7162107c8119b03c0ce2c9a2ff7bed70c98";
const PROVIDER = new ethers.providers.JsonRpcProvider(); // local
var questions = await getRegisterEvents(PROVIDER, ASI_ADDRESS, 7888888, 1669605640211)
    .then(getQuestions);
console.log(questions);

const pk = "0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba";
const a = await getOpinionatedSecret(new Wallet(pk), "0x35");
console.log(a);
*/