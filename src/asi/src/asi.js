import { ethers } from "ethers"
import { poseidon } from "circomlibjs"; // for getQuestion()


// don't hide ethers.js

class ASI {
    static ABI = [
        "event Register(uint indexed sessionId, uint question, address standIn)",
        "event Proof(uint indexed sessionId, address user)",
        "error ZeroUserTreeRootError()",
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
    static TEMP_ADDR = "0x00a9a7162107c8119b03c0ce2c9a2ff7bed70c98";
    /*
    const { ASI } = require("asi");
    //const provider = new ethers.providers.JsonRpcProvider(); // local
    const userSigner = new ethers.Wallet("0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d", provider);
    const asiSigner = new ethers.Wallet("0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e", provider);
    const asi = new ASI(ASI.TEMP_ADDR, userSigner, asiSigner);
    */
    // HAS A Contract
    //static getXXX(){}
    constructor(contractAddr, userSigner, asiSigner) {
        this.contract = new ethers.Contract(contractAddr, ASI.ABI, userSigner);
        this.userSigner = userSigner;
        this.asiSigner = asiSigner;
    }
    getUserSigner() {
        return this.userSigner;
    }
    getAsiSigner() {
        return this.asiSigner;
    }
    // Promise
    getUserAddress() {
        return this.userSigner.getAddress();
    }
    // create a new session
    // returns a promise of tx
    createSession(sessionId, userTreeRoot) {
        return this.contract.createSession(sessionId, userTreeRoot);
    }

    getUserTreeRoot(sessionId) {
        return this.contract.getUserTreeRoot(sessionId);
    }
    getOpinionatedSecret(sessionId) {
        return this.asiSigner.signMessage(sessionId.toString())
            .then(s => BigInt(ethers.utils.keccak256(ethers.utils.toUtf8Bytes(s))));
    }
    static getQuestion(userAddr, secret) {
        return poseidon([userAddr, secret]);
    }
    // Promise
    getOpinionatedQuestion(sessionId) {
        return Promise.all([this.getUserAddress(), this.getOpinionatedSecret(sessionId)])
            .then(([userAddr, secret]) => getQuestion(userAddr, secret))
            ;
    }

    // you have to make sure that you are in the user tree before calling register
    register(sessionId, question) {
        return this.contract.connect(this.asiSigner).register(sessionId, question);
    }
    /*
    getRegisterEvents(sessionId)
    static extractQuestions
    static getOpinionatedSecret
    static getQuestion
    register()
    */
}
export { ASI };