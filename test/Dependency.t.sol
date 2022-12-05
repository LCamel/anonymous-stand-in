// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { PoseidonT3 } from "incremental-merkle-tree.sol/Hashes.sol";
import "incremental-merkle-tree.sol/IncrementalBinaryTree.sol";

contract DependencyTest is Test {
    using IncrementalBinaryTree for IncrementalTreeData;

    function testPoseidon() public {
        //assertEq(PoseidonT3.poseidon([uint(1), uint(2)]), 7853200120776062878684798364095072458815029376092732009249414926327459813530);
        if (PoseidonT3.poseidon([uint(1), uint(2)]) != 7853200120776062878684798364095072458815029376092732009249414926327459813530) {
            string memory errorMsg =
                "\n"
                "###############################################################\n"
                "#                                                             #\n"
                "#                                                             #\n"
                "#     bad Poseidon(1, 2) result                               #\n"
                "#     run 'forge test' with linker settings (--libraries).    #\n"
                "#                                                             #\n"
                "#                                                             #\n"
                "###############################################################\n"
                ;
            fail(errorMsg);
        }
    }
    /*
    var { poseidon } = require("circomlibjs");
    var { IncrementalMerkleTree } = require("@zk-kit/incremental-merkle-tree");
    t = new IncrementalMerkleTree(poseidon, 5, 0, 2);
    console.log(t.root); // 19712377064642672829441595136074946683621277828620209496774504837737984048981n
    t.insert(BigInt(1));
    console.log(t.root); // 2198688200817217279804184813425808109663645328240240708703506126151229416864n

    */
    IncrementalTreeData tree;
    function testIncrementalMerkleTree() public {
        tree.init(5, 0);
        assertEq(tree.root, 19712377064642672829441595136074946683621277828620209496774504837737984048981);
        tree.insert(1);
        assertEq(tree.root, 2198688200817217279804184813425808109663645328240240708703506126151229416864);
    }
}