// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import "forge-std/console.sol";
import "./anonymous_stand_in_generated_verifier.sol";

contract AnonymousStandIn {
    using IncrementalBinaryTree for IncrementalTreeData;

    event Register(address standIn, uint question);
    event Proof(address user);

    error AlreadyProofedError();
    error VerificationError();

    uint private _userTreeRoot;
    IncrementalTreeData private _questions;
    IncrementalTreeData private _standIns;
    bool[10000000] private _proofed; // TODO: confirm cost / bound

    Verifier private _verifier = new Verifier();

    constructor(uint userTreeRoot) {
        _userTreeRoot = userTreeRoot;
        _questions.init(5, 0);
        _standIns.init(5, 0);
    }

    function createSession(uint userTreeRoot) public {
        _userTreeRoot = userTreeRoot;
    }

    function register(uint question) public {
        // TODO: $
        // TODO: dedup for UX
        _questions.insert(question);
        _standIns.insert(uint160(msg.sender));
        emit Register(address(uint160(msg.sender)), question);
        console.log("register: sender: %s questions root: %d standIns root: %d",
            msg.sender, _questions.root, _standIns.root);
    }

    function proof(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint userIndex) public returns (bool r) {
        console.log("proof: sender: %s userIndex: %d", msg.sender, userIndex);
        console.log("proof: _userTreeRoot: %d", _userTreeRoot);
        console.log("proof: _questions.root: %d", _questions.root);
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
        if (_proofed[userIndex]) {
            console.log("AlreadyProofedError: userIndex: %d", userIndex);
            revert AlreadyProofedError();
        }

        // dev: see the .sym for the order of the values
        // or see the result of "snarkjs generatecall"

        if(! _verifier.verifyProof(
            a, b, c, [_userTreeRoot, userIndex, _questions.root, uint160(msg.sender)])) {
            console.log("verification error: ", a[0]);
            //, a[1], b[0][0], b[0][1], b[1][0], b[1][1], c[0], c[1], userIndex);
            revert VerificationError();
        }

        _proofed[userIndex] = true;

        emit Proof(msg.sender);
        return true;
        // TODO: $
    }
}
