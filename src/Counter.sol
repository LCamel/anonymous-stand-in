// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "incremental-merkle-tree.sol/IncrementalBinaryTree.sol";

import "forge-std/console.sol";

contract Counter {
    using IncrementalBinaryTree for IncrementalTreeData;
    uint256 public number;
    IncrementalTreeData private tree;

    event T1(uint256 n);

    constructor() {
        tree.init(5, 0);
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
        uint val = number * number;
        tree.insert(val);
        console.log("val: %d root: %d", val, tree.root);
    }
}
