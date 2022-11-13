#!/bin/sh

# use the first anvil account
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# use the address from semaphore
# TODO: extract to foundry.toml (?)
forge script script/AnonymousStandIn.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --libraries=incremental-merkle-tree.sol/Hashes.sol:PoseidonT3:0xe0A452533853310C371b50Bd91BB9DCC8961350F --libraries=incremental-merkle-tree.sol/IncrementalBinaryTree.sol:IncrementalBinaryTree:0x61AE89E372492e53D941DECaaC9821649fa9B236
