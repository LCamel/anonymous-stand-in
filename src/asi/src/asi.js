import { ethers } from "ethers"
import { poseidon } from "circomlibjs"; // for getQuestion()


// dev: don't hide ethers.js

const ABI = [
    "event CreateSession(uint indexed sessionId, uint userTreeRoot, uint value)",
    "event Register(uint indexed sessionId, uint question, address standIn)",
    "event Proof(uint indexed sessionId, address user)",
    "error ZeroSessionIdError()",
    "error ZeroUserTreeRootError()",
    "error ZeroQuestionError()",
    "error SessionAlreadyExistsError()",
    "error SessionDoesNotExistError()",
    "error ValueMismatchError()",
    "error AlreadyProofedError()",
    "error VerificationError()",
    "error SendError()",
    "function createSession(uint sessionId, uint userTreeRoot, uint value) public",
    "function getUserTreeRoot(uint sessionId) public view returns (uint)",
    "function getQuestionTreeRoot(uint sessionId) public view returns (uint)",
    "function getValue(uint sessionId) public view returns (uint)",
    "function register(uint sessionId, uint question) public payable",
    "function proof(uint sessionId, uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint userIndex) public",
    ];

const TEMP_ADDR = "0x00a9a7162107c8119b03c0ce2c9a2ff7bed70c98";

class UserSide {
    constructor(contractAddress, userAddress, userSigner) {
        this.contract = new ethers.Contract(contractAddress, ABI, userSigner);
        this.userAddress = ethers.utils.getAddress(userAddress);
        this.userSigner = userSigner;
    }
    // create a new session
    // returns a promise of tx
    createSession(sessionId, userTreeRoot, value) {
        return this.contract.createSession(sessionId, userTreeRoot, value);
    }
    // Promise: get from the contract on the chain
    getUserTreeRoot(sessionId) {
        return this.contract.getUserTreeRoot(sessionId);
    }
    getQuestionTreeRoot(sessionId) {
        return this.contract.getQuestionTreeRoot(sessionId);
    }

    // TODO: getQuestionsRoot ?

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

class ASISide {
    constructor(contractAddress, userAddress, asiSigner) {
        this.contract = new ethers.Contract(contractAddress, ABI, asiSigner);
        this.userAddress = ethers.utils.getAddress(userAddress);
        this.asiSigner = asiSigner;
    }

    // question = hash(userAddress, secret)
    static getQuestion(userAddress, secret) {
        return poseidon([userAddress, secret]);
    }

    getQuestion(secret) {
        return ASISide.getQuestion(this.userAddress, secret);
    }
    // Promise
    getValue(sessionId) {
        return this.contract.getValue(sessionId);
    }

    // You have to make sure that you are in the user tree before calling register.
    // If not, you will not be able to call prove() to get back the fund.
    // Promise
    register(sessionId, question, value) {
        return this.contract.register(sessionId, question, { value });
    }

    // A more convenient version of register().
    // It will compute the question from secret, and fetch the value from the contract.
    // Promise
    registerAuto(sessionId, secret) {
        const question = ASISide.getQuestion(this.userAddress, secret);
        return this.contract.getValue(sessionId)
            .then((value) => this.register(sessionId, question, value));
    }

    // Promise: secret = sign_by_ASI(sessionId)
    getOpinionatedSecret(sessionId) {
        return this.asiSigner.signMessage(sessionId.toString())
            .then((s) => BigInt(ethers.utils.keccak256(ethers.utils.toUtf8Bytes(s))));
    }

    // Since the User side need the secret, I think it is better to
    // call getOpinionatedSecret() and getQuestion() separately.
    //
    // Promise
    //getOpinionatedQuestion(sessionId) {
    //    return this.getOpinionatedSecret(sessionId)
    //        .then((secret) => ASISide.getQuestion(this.userAddress, secret))
    //        ;
    //}
}

export { UserSide, ASISide, ABI, TEMP_ADDR };