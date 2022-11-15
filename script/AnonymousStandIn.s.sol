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
        vm.startBroadcast(userPrivateKeys[1]);
        asi.proof(
            [
                uint(0x0f74723f7c825c84a3c349465348bf24e36817bb7b0bd8923c8bc293c506268b),
                uint(0x24abf7977393a42deae055a7b41a42cb244f3d27463747e828b2b60094629ac3)
            ], [
                [
                    uint(0x03eae35f730f4f408a4d1a3943b2533af616ad559641d02cccd30e7d2daafb88),
                    uint(0x2bfdf5e1dbe0767fb485d1319278bdbc4c61d4affbfb7544a7474ac5b9196723)
                ], [
                    uint(0x21b9ad8c10bb766e999095efdffa405747f4112fa80a91d87aa61e23a9d264d4),
                    uint(0x0c47f75362a60f2317a1785784a6516df82b70519a3a9477715e98a041bf355a)
                ]
            ], [
                uint(0x11ec0592969afe0052914b3e34e92c1a713f708132ef5baca1b7303df2262709),
                uint(0x058e508353430723f44fe602c569d7ca50a4bdd7828f2489d472d0603a5e5fed)
            ],
            1
        );
        vm.stopBroadcast();
    }
}
