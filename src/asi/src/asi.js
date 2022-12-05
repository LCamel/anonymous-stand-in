import { ethers } from "ethers"
import { poseidon } from "circomlibjs"; // for getQuestion()


// dev: don't hide ethers.js

const ABI = [
    "event CreateSession(uint indexed sessionId, uint userTreeRoot)",
    "event Register(uint indexed sessionId, uint question, address standIn)",
    "event Proof(uint indexed sessionId, address user)",
    "error ZeroSessionIdError()",
    "error ZeroUserTreeRootError()",
    "error ZeroQuestionError()",
    "error SessionAlreadyExistsError()",
    "error SessionDoesNotExistError()",
    "error AlreadyProofedError()",
    "error VerificationError()",
    "function createSession(uint sessionId, uint userTreeRoot)",
    "function getUserTreeRoot(uint sessionId) public view returns (uint)",
    "function getQuestionTreeRoot(uint sessionId) public view returns (uint)",
    "function register(uint sessionId, uint question)",
    "function proof(uint sessionId, uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint userIndex) public returns (bool r)",
];

const TEMP_ADDR = "0x00a9a7162107c8119b03c0ce2c9a2ff7bed70c98";

class User {
    constructor(contractAddress, userAddress, userSigner) {
        this.contract = new ethers.Contract(contractAddress, ABI, userSigner);
        this.userAddress = userAddress;
        this.userSigner = userSigner;
    }
    // create a new session
    // returns a promise of tx
    createSession(sessionId, userTreeRoot) {
        return this.contract.createSession(sessionId, userTreeRoot);
    }
    // Promise: get from the contract on the chain
    getUserTreeRoot(sessionId) {
        return this.contract.getUserTreeRoot(sessionId);
    }
    // Promise: register events (ethers.js)
    getRegisterEvents(sessionId) {
        const filter = this.contract.filters.Register(sessionId);
        return this.contract.queryFilter(filter);
    }
    // Promise: questions (BigInts)
    getQuestions(sessionId) {
        return this.getRegisterEvents(sessionId)
            .then((events) => events.map((event) => event.args.question.toBigInt()));
    }
    // Promise: tx
    proof(sessionId, proofAndPublicSignals) {
        const { proof, publicSignals } = proofAndPublicSignals;
        const a = [ proof.pi_a[0], proof.pi_a[1] ];
        const b = [[ proof.pi_b[0][1], proof.pi_b[0][0] ],
                   [ proof.pi_b[1][1], proof.pi_b[1][0] ]];
        const c = [ proof.pi_c[0],  proof.pi_c[1] ];
        const userIndex = publicSignals[1];
        return this.contract.proof(sessionId, a, b, c, userIndex);
    }
}

class ASI {
    constructor(contractAddress, userAddress, asiSigner) {
        this.contract = new ethers.Contract(contractAddress, ABI, asiSigner);
        this.userAddress = userAddress;
        this.asiSigner = asiSigner;
    }
    // Promise: secret = signByAsi(sessionId)
    getOpinionatedSecret(sessionId) {
        return this.asiSigner.signMessage(sessionId.toString())
            .then((s) => BigInt(ethers.utils.keccak256(ethers.utils.toUtf8Bytes(s))));
    }
    // question = hash(userAddress, secret)
    static getQuestion(userAddress, secret) {
        return poseidon([userAddress, secret]);
    }
    // Promise
    getOpinionatedQuestion(sessionId) {
        return this.getOpinionatedSecret(sessionId)
            .then((secret) => ASI.getQuestion(this.userAddress, secret))
            ;
    }
    // you have to make sure that you are in the user tree before calling register
    // if not, you will not be able to call prove() to get back the fund
    register(sessionId, question) {
        return this.contract.connect(this.asiSigner).register(sessionId, question);
    }
}

export { ASI, User, TEMP_ADDR };