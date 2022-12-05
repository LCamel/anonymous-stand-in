// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { PoseidonT3 } from "incremental-merkle-tree.sol/Hashes.sol";
import "incremental-merkle-tree.sol/IncrementalBinaryTree.sol";

contract DependencyTest is Test {
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
}