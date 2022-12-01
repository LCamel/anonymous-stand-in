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

function getQuestions(registerEvents) {
    return registerEvents.map((event) => event.args.question.toBigInt());
}

// Promise: keccak256 of signed sessionId
function getOpinionatedSecret(signer, sessionId) {
    return signer.signMessage(BigInt(sessionId).toString())
        .then(s => BigInt(ethers.utils.keccak256(ethers.utils.toUtf8Bytes(s))));
}


export { getRegisterEvents, getQuestions, getOpinionatedSecret };
export * from "./asi_proof.js";