// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/AnonymousStandIn.sol";
import "incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import "incremental-merkle-tree.sol/Hashes.sol";

contract AnonymousStandInScript is Script {
    using IncrementalBinaryTree for IncrementalTreeData;
    IncrementalTreeData private _userTreeData;

    function setUp() public {}

    function run() public {
        uint[5] memory userPrivateKeys = [
            vm.envUint("PRIVATE_KEY_0"),
            vm.envUint("PRIVATE_KEY_1"),
            vm.envUint("PRIVATE_KEY_2"),
            vm.envUint("PRIVATE_KEY_3"),
            vm.envUint("PRIVATE_KEY_4")
        ];
        uint[5] memory asiPrivateKeys = [
            vm.envUint("PRIVATE_KEY_5"),
            vm.envUint("PRIVATE_KEY_6"),
            vm.envUint("PRIVATE_KEY_7"),
            vm.envUint("PRIVATE_KEY_8"),
            vm.envUint("PRIVATE_KEY_9")
        ];

        // simulating the client-side tree root computation
        _userTreeData.init(5, 0);
        for (uint i = 0; i < userPrivateKeys.length; i++) {
            address userAddr = vm.addr(userPrivateKeys[i]);
            _userTreeData.insert(uint160(userAddr));
            console.log("insert: ", userAddr);
            console.log("root: ", _userTreeData.root);
        }

        // deploy
        uint deployerPrivateKey = userPrivateKeys[0];
        vm.startBroadcast(deployerPrivateKey);
        AnonymousStandIn asi = new AnonymousStandIn(_userTreeData.root);
        vm.stopBroadcast();
        console.log("==== deployed: ", address(asi));

        // register
        for (uint i = 0; i < 3; i++) {
            // generate the question for the userAddr
            address userAddr = vm.addr(userPrivateKeys[i]);
            uint secret = i * 10;
            uint question = PoseidonT3.poseidon([uint160(userAddr), secret]);
            console.log("question: ", question);

            // register with the asi addr
            vm.startBroadcast(asiPrivateKeys[i]);
            asi.register(question);
            vm.stopBroadcast();
        }

        // proof (see generateInput.sh / c.sh)
        uint[2] memory a = [
                uint(0x11ba4d3778c9563d33c0e2c4db3e3f4e0c95d4da5451870f6ee45ae6ca388184),
                uint(0x0a48ab5b0b781646ccde28153149dc6887b5e05c53baf2f3878472e06f48d76c)
            ];
        uint[2][2] memory b = [
                [
                    uint(0x143569355a5d0073d5937d5aa81273eb5a1214202e80f5bb186a4485f1c93e3a),
                    uint(0x1cda5c1f819cb3a45f99aa284b05a70a545f3eb009fdeecc5c6e98862570692b)
                ], [
                    uint(0x0b6c8e03a8e0bea78ad75aa5913907c4122bace72d10939508e4a84f97a18f67),
                    uint(0x0f42dc8ef52047c3f87cfb9d5208d659ec6a3edd17d3bcc6752e435f18543258)
                ]
            ];
        uint[2] memory c = [
                uint(0x0803be147c309732816c47f3272fedac8e4d26cff229a91ca851857d73065a50),
                uint(0x04c432538d4a2302cfef8a4c4397f96c286b9dad3eb222975d57e1d16b911ee3)
            ];

        vm.startBroadcast(userPrivateKeys[1]);
        asi.proof(a, b, c, 1);
        vm.stopBroadcast();
    }
}
