// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "incremental-merkle-tree.sol/IncrementalBinaryTree.sol";

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
        tree.insert(number * number);
        emit T1(tree.numberOfLeaves);
    }
}
