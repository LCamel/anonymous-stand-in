// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/AnonymousStandIn.sol";

contract AnonymousStandInTest is Test {
    AnonymousStandIn public anonymousStandIn;

    function setUp() public {
        anonymousStandIn = new AnonymousStandIn(4242);
    }

    function testRegister() public {
        anonymousStandIn.register(1);
        anonymousStandIn.register(2);
        anonymousStandIn.register(3);
    }
}
