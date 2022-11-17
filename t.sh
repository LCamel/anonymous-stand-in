#!/bin/sh

# use a pre-deployed address from semaphore
# https://github.com/semaphore-protocol/semaphore/blob/main/packages/contracts/deployed-contracts/goerli.json
# 0xe0A452533853310C371b50Bd91BB9DCC8961350F

# use the anvil test accounts
export PRIVATE_KEY_0=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export PRIVATE_KEY_1=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
export PRIVATE_KEY_2=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
export PRIVATE_KEY_3=0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6
export PRIVATE_KEY_4=0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a
export PRIVATE_KEY_5=0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba
export PRIVATE_KEY_6=0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e
export PRIVATE_KEY_7=0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356
export PRIVATE_KEY_8=0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97
export PRIVATE_KEY_9=0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6


time forge test --fork-url https://eth-goerli.g.alchemy.com/v2/demo --fork-block-number 7888888 --libraries=incremental-merkle-tree.sol/Hashes.sol:PoseidonT3:0xe0A452533853310C371b50Bd91BB9DCC8961350F -vv

# anvil --fork-url https://eth-goerli.g.alchemy.com/v2/demo --fork-block-number 7888888
#time forge test --fork-url http://127.0.0.1:8545 --fork-block-number 7888888 --libraries=incremental-merkle-tree.sol/Hashes.sol:PoseidonT3:0xe0A452533853310C371b50Bd91BB9DCC8961350F -vv
