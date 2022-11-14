// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/AnonymousStandIn.sol";

contract AnonymousStandInScript is Script {
    function setUp() public {}

    function run() public {
        uint256 pk0 = vm.envUint("PRIVATE_KEY_0");
        uint256 pk1 = vm.envUint("PRIVATE_KEY_1");
        uint256 pk2 = vm.envUint("PRIVATE_KEY_2");
        uint256 pk3 = vm.envUint("PRIVATE_KEY_3");

        uint256 deployerPrivateKey = pk0;
        vm.startBroadcast(deployerPrivateKey);
        AnonymousStandIn asi = new AnonymousStandIn(14491587431966538270500950809981262305760918678010866824965324294330536670835);
        vm.stopBroadcast();

        vm.startBroadcast(pk1);
        asi.register(11);
        vm.stopBroadcast();

        vm.startBroadcast(pk2);
        asi.register(22);
        vm.stopBroadcast();
    }
}
