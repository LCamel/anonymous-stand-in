// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import "forge-std/console.sol";

contract AnonymousStandIn {
    using IncrementalBinaryTree for IncrementalTreeData;

    uint private _userTreeRoot;
    IncrementalTreeData private _questions;

    constructor(uint userTreeRoot) {
        _userTreeRoot = userTreeRoot;
        _questions.init(5, 0);
    }

    function register(uint question) public {
        _questions.insert(question);
        console.log(_questions.root);
    }
}
