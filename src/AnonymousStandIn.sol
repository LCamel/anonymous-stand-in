// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import "forge-std/console.sol";
import "./anonymous_stand_in_generated_verifier.sol";

contract AnonymousStandIn {
    using IncrementalBinaryTree for IncrementalTreeData;

    //event Register(address standIn, uint question);
    event Proof(address user);

    uint private _userTreeRoot;
    IncrementalTreeData private _questions;
    IncrementalTreeData private _standIns;

    Verifier private _verifier = new Verifier();

    constructor(uint userTreeRoot) {
        _userTreeRoot = userTreeRoot;
        _questions.init(5, 0);
        _standIns.init(5, 0);
    }

    function register(uint question) public {
        // TODO: $
        // TODO: dedup
        _questions.insert(question);
        _standIns.insert(uint160(msg.sender));
        console.log("register: sender: %s questions root: %d standIns root: %d",
            msg.sender, _questions.root, _standIns.root);
    }

    function proof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint userIndex
        ) public returns (bool r) {
        // see the .sym for the order of the values
        // or see the result of "snarkjs generatecall"
        require(_verifier.verifyProof(
            a, b, c, [_userTreeRoot, userIndex, _questions.root, uint160(msg.sender)]),
            "verification failed");
        emit Proof(msg.sender);
        return true;
        // TODO: dedup
        // TODO: $
    }
}
