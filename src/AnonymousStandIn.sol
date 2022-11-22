// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import "forge-std/console.sol";
import "./anonymous_stand_in_generated_verifier.sol";

contract AnonymousStandIn {
    using IncrementalBinaryTree for IncrementalTreeData;

    event Register(uint indexed sessionId, uint question, address standIn);
    event Proof(uint indexed sessionId, address user);

    error ZeroUserTreeRootError();
    error SessionAlreadyExistsError();
    error SessionDoesNotExistError();
    error AlreadyProofedError();
    error VerificationError();

    struct SessionData {
        uint userTreeRoot;
        IncrementalTreeData questions;
        IncrementalTreeData standIns;
        bool[10000000] proofed; // TODO: confirm cost / bound
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

    function createSession(uint sessionId, uint userTreeRoot) public {
        console.log("createSession: sessionId: %d userTreeRoot: %d", sessionId, userTreeRoot);
        if (userTreeRoot == 0) {
            revert ZeroUserTreeRootError();
        }
        SessionData storage session = _sessions[sessionId];
        if (session.userTreeRoot != 0) {
            revert SessionAlreadyExistsError();
        }
        session.userTreeRoot = userTreeRoot;
        session.questions.init(5, 0);
        console.log("createSession: session.questions.root: %d", session.questions.root);
        session.standIns.init(5, 0);
        console.log("createSession: _sessions[sessionId].userTreeRoot: %d", _sessions[sessionId].userTreeRoot);
        // TODO: emit
    }
    // a user can verify the user tree root before calling register()
    function getUserTreeRoot(uint sessionId) public view returns (uint) {
        return _sessions[sessionId].userTreeRoot;
    }
    // a user can verify the question tree root before calling proof()
    function getQuestionTreeRoot(uint sessionId) public view returns (uint) {
        return _sessions[sessionId].questions.root;
    }
    function register(uint sessionId, uint question) public {
        // TODO: $
        // TODO: dedup for UX
        //console.log("register: sessionId: %d question: %d", sessionId, question);
        //console.log("register: _sessions[sessionId].userTreeRoot: %d", _sessions[sessionId].userTreeRoot);
        SessionData storage session = _sessions[sessionId];
        //console.log("register: session.userTreeRoot: %d", session.userTreeRoot);
        if (session.userTreeRoot == 0) {
            revert SessionDoesNotExistError();
        }
        session.questions.insert(question);
        session.standIns.insert(uint160(msg.sender));
        emit Register(sessionId, question, address(uint160(msg.sender)));
        console.log("register: sender: %s sessionId: %d", msg.sender, sessionId);
        console.log("register: questions root: %d standIns root: %d", session.questions.root, session.standIns.root);
    }

    function proof(uint sessionId, uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint userIndex) public returns (bool r) {
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
        emit Proof(sessionId, msg.sender);
        return true;
        // TODO: $
    }
}
