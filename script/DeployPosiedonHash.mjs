// SEE: deploy-semaphore.ts from Semaphore

import { poseidon_gencontract } from "circomlibjs";
import { ethers } from "ethers";
import { poseidon } from "circomlibjs"; // for verifying only

//const provider = new ethers.providers.JsonRpcProvider(); // local
//const provider = new ethers.providers.AlchemyProvider("goerli", "demo");
//const privKey = "0x0";

const signer = new ethers.Wallet(privKey, provider);


for (let nInputs = 2; nInputs <= 6; nInputs++) {

console.log("==== nInputs: " + nInputs);

const poseidonABI = poseidon_gencontract.generateABI(nInputs).slice(1, 2); // no overloading
const poseidonBytecode = poseidon_gencontract.createCode(nInputs);

//console.log("==== sliced ABI: ");
//console.log(JSON.stringify(poseidonABI, undefined, 4));
console.log("bytecode length: " + poseidonBytecode.length);

const factory = new ethers.ContractFactory(poseidonABI, poseidonBytecode, signer)
const contract = await factory.deploy();
console.log("will be deployed at addr: " + contract.address);
//await contract.deployed();
//console.log("deployed.");
const receipt = await contract.deployTransaction.wait();
console.log("deployed. gasUsed: " + receipt.gasUsed.toBigInt());

const inputs = [1, 2, 3, 4, 5, 6].slice(0, nInputs);
console.log("inputs: " + inputs);

// using the newly deployed contract
const ans = await contract.poseidon(inputs);
console.log(ans.toBigInt());
// using javascript
console.log(poseidon(inputs));

const gas = await contract.estimateGas.poseidon(inputs);
console.log("estimated gas: " + gas);

}
