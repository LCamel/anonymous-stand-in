// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/AnonymousStandIn.sol";

contract AnonymousStandInScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        AnonymousStandIn asi = new AnonymousStandIn(14491587431966538270500950809981262305760918678010866824965324294330536670835);
        vm.stopBroadcast();
    }
}
