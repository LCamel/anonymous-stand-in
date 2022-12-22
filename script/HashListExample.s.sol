// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/HashListExample.sol";

contract HashListTestScript is Script {

    function setUp() public {}

    function run() public {
        uint[5] memory userPrivateKeys = [
            vm.envUint("PRIVATE_KEY_0"),
            vm.envUint("PRIVATE_KEY_1"),
            vm.envUint("PRIVATE_KEY_2"),
            vm.envUint("PRIVATE_KEY_3"),
            vm.envUint("PRIVATE_KEY_4")
        ];
        uint deployerPrivateKey = userPrivateKeys[0];

        vm.startBroadcast(deployerPrivateKey);
        {
            HashListExample2 hle = new HashListExample2();
            for (uint i = 1; i <= 13; i++) {
                hle.add(i);
            }
        }
        vm.stopBroadcast();
        //console.log("==== deployed: ", address(hle));
    }
}
