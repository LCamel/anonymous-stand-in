// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/AnonymousStandIn.sol";

contract AnonymousStandInTest is Test {
    AnonymousStandIn public anonymousStandIn;
    address u_a = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address u_b = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address u_c = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address u_d = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    address u_e = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;

    address s_a = 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc;
    address s_b = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;
    address s_c = 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955;
    address s_d = 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f;
    address s_e = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;

    function setUp() public {
        anonymousStandIn = new AnonymousStandIn(14491587431966538270500950809981262305760918678010866824965324294330536670835);
    }

    function testRegister() public {
        // use stand-in accounts to interact with the contract
        vm.prank(s_d);
        anonymousStandIn.register(123);
        vm.prank(s_e);
        anonymousStandIn.register(14992967248067620736906915151099623099783214469663224091377866644517376473097);
        vm.prank(s_a);
        anonymousStandIn.register(456);
        vm.prank(s_b);
        anonymousStandIn.register(789);

        vm.prank(u_e);
        anonymousStandIn.proof(
[uint(0x094e4e09588058b75a6a0b7b764cf369596f8b16082ae70285d66ffb13c142b7),
uint(0x19197caa3c1b8745cc9b95e8440135200ea6f541951c7b8f0727fdcfc5f2b11b)],

[[uint(0x260a6e9d4e053d6a6e1be5f7c35388d7ad03be71e8ecb817cf43d481302e7680),
uint(0x222da4a9509f1b7412b49ff1546844ec292ba7780f7620c7c9b800f242d10f3c)],
[uint(0x0a8e36f995b31cac55d7a1c1251f4efbde278e415ac0874db6766f05071cb053),
uint(0x090536dfa53bbd4e52f38df3e5f33988b5a66b799f32db9c54e6b43d24ea78ff)]],

[uint(0x2c554665e2eada2cf21b530bb0413e5dec6d6ad639689aa52fc28231676bb5b8),
uint(0x159b7d219e7c5d8aaaf08704550f5ee1e5ea2a2ecd4177cef28ded9e09360431)],

4
        );
    }
}
