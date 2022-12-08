// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import "forge-std/console.sol";
import "./anonymous_stand_in_generated_verifier.sol";

contract AnonymousStandIn {
    using IncrementalBinaryTree for IncrementalTreeData;

    event CreateSession(uint indexed sessionId, uint userTreeRoot, uint value);
    event Register(uint indexed sessionId, uint question, address standIn);
    event Proof(uint indexed sessionId, address user);

    error ZeroSessionIdError();
    error ZeroUserTreeRootError();
    error ZeroQuestionError();
    error SessionAlreadyExistsError();
    error SessionDoesNotExistError();
    error ValueMismatchError();
    error AlreadyProofedError();
    error VerificationError();
    error SendError();

    struct SessionData {
        uint userTreeRoot;
        IncrementalTreeData questions;
        IncrementalTreeData standIns;
        bool[10000000] proofed; // TODO: confirm cost / bound
        uint value;
    }

    mapping(uint => SessionData) private _sessions;
    Verifier private _verifier = new Verifier();

    /*
    constructor(uint userTreeRoot) {
        _userTreeRoot = userTreeRoot;
        _questions.init(5, 0);
        _standIns.init(5, 0);
    }
    */

    function createSession(uint sessionId, uint userTreeRoot, uint value) public {
        console.log("createSession: sessionId: %d userTreeRoot: %d value: %d", sessionId, userTreeRoot, value);
        if (sessionId == 0) {
            revert ZeroSessionIdError();
        }
        if (userTreeRoot == 0) {
            revert ZeroUserTreeRootError();
        }
        SessionData storage session = _sessions[sessionId];
        if (session.userTreeRoot != 0) {
            revert SessionAlreadyExistsError();
        }
        session.userTreeRoot = userTreeRoot;
        session.questions.init(5, 0);
        session.standIns.init(5, 0);
        session.value = value;
        emit CreateSession(sessionId, userTreeRoot, value);
    }
    // a user can verify the user tree root before calling register()
    // if the session does not exist, return 0
    function getUserTreeRoot(uint sessionId) public view returns (uint) {
        if (sessionId == 0) {
            revert ZeroSessionIdError();
        }
        return _sessions[sessionId].userTreeRoot;
    }

    // a user can verify the question tree root before calling proof()
    function getQuestionTreeRoot(uint sessionId) public view returns (uint) {
        if (sessionId == 0) {
            revert ZeroSessionIdError();
        }
        return _sessions[sessionId].questions.root;
    }

    function getValue(uint sessionId) public view returns (uint) {
        if (sessionId == 0) {
            revert ZeroSessionIdError();
        }
        return _sessions[sessionId].value;
    }

    function register(uint sessionId, uint question) public payable {
        if (sessionId == 0) {
            revert ZeroSessionIdError();
        }
        if (question == 0) {
            revert ZeroQuestionError();
        }
        SessionData storage session = _sessions[sessionId];
        if (session.userTreeRoot == 0) {
            revert SessionDoesNotExistError();
        }
        if (msg.value != session.value) {
            revert ValueMismatchError();
        }
        session.questions.insert(question);
        session.standIns.insert(uint160(msg.sender));
        emit Register(sessionId, question, address(uint160(msg.sender)));
    }

    function proof(uint sessionId, uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint userIndex) public {
        if (sessionId == 0) {
            revert ZeroSessionIdError();
        }
        SessionData storage session = _sessions[sessionId];
        if (session.userTreeRoot == 0) {
            revert SessionDoesNotExistError();
        }

        console.log("proof: sessionId: %d", sessionId);
        console.log("proof: sender: %s userIndex: %d", msg.sender, userIndex);
        console.log("proof: session.userTreeRoot: %d", session.userTreeRoot);
        console.log("proof: session.questions.root: %d", session.questions.root);
        console.log("proof: a %d", a[0]);
        console.log("proof: a %d", a[1]);
        console.log("proof: b %d", b[0][0]);
        console.log("proof: b %d", b[0][1]);
        console.log("proof: b %d", b[1][0]);
        console.log("proof: b %d", b[1][1]);
        console.log("proof: c %d", c[0]);
        console.log("proof: c %d", c[1]);


        // every user should only proof once
        // dev: verify this cheap condition first
        if (session.proofed[userIndex]) {
            console.log("AlreadyProofedError: sessionId: %d userIndex: %d", sessionId, userIndex);
            revert AlreadyProofedError();
        }

        // dev: see the .sym for the order of the values
        // or see the result of "snarkjs generatecall"
        if(! _verifier.verifyProof(
            a, b, c, [session.userTreeRoot, userIndex, session.questions.root, uint160(msg.sender)])) {
            console.log("verification error: ", a[0]);
            //, a[1], b[0][0], b[0][1], b[1][0], b[1][1], c[0], c[1], userIndex);
            revert VerificationError();
        }

        session.proofed[userIndex] = true;
        console.log("proof: mark userIndex as proofed: %d", userIndex);

        // might revert
        if (! payable(msg.sender).send(session.value)) {
            revert SendError();
        }

        emit Proof(sessionId, msg.sender);
    }
}
