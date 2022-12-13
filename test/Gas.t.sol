// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract Gas is Test {
    uint256[100] arr = [ 0, 1, 2, 3, 0, 1, 2, 3 ];
    function testDoNothing() public {
    }
    function testWriteArrayZeroToNonZero() public {
        arr[0] = 42;
    }
    function testWriteArrayZeroToNonZero2() public {
        arr[4] = 42;
    }
    function testWriteArrayNonZeroToNonZero() public {
        arr[1] = 42;
    }
    function testWriteArrayNonZeroToNonZero2() public {
        arr[5] = 42;
    }
    function testIncrementNonZero() public {
        uint x = arr[6] + 1;
        arr[6] = x;
    }
    function testWriteOriginal() public {
        arr[7] = 42;
        if (block.number > 1) {
            arr[7] = 3;
        }
    }
}