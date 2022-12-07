import { IncrementalMerkleTree } from "@zk-kit/incremental-merkle-tree";
import { poseidon } from "circomlibjs";
import { Contract, ethers, Signer, Wallet } from "ethers";
import { wtns, groth16 } from "snarkjs";
console.log("wtns: " , wtns);
console.log("groth16: " , groth16);
console.log(poseidon([1, 2]));

const userPrivKeys = [
    "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
    "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d",
    "0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a",
    "0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
    "0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a",
    ];
const asiPrivKeys = [
    "0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba",
    "0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e",
    "0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356",
    "0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97",
    "0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6",
    ];
//const questions = userPrivKeys.map((key, i) => poseidon(key, i * 10));

const provider = new ethers.providers.JsonRpcProvider(); // local
const userSigners = userPrivKeys.map((key) => new Wallet(key, provider));
const asiSigners = asiPrivKeys.map((key) => new Wallet(key, provider));

const asiContract = new Contract(
    "0x00a9a7162107c8119b03c0ce2c9a2ff7bed70c98",
    [
        "function createSession(uint userTreeRoot) public",
        "function register(uint question) public",
        `function proof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint userIndex
        ) public returns (bool r)`,
        "event Register(address standIn, uint question)",
        "event Proof(address user)",
    
        "error AlreadyProofedError()",
        "error VerificationError()",
    ],
    provider
    );

const a = [
    BigInt("0x0044b93b0679367b30225b6cc5bec792ba5f77f5996d697c6df7e9a40793898a"),
    BigInt("0x0468eee9c9120069e04bc4d00d36d879e31c6addf3082ae10f8f104eb14c7c45")];
const b = [
    [BigInt("0x0fecee0fb02f62a1c1b0097d21daddb7f68105c9493ad1184c7d9e6ae1ab3432"),
        BigInt("0x302129e6f61fcb1215f5aee1174eba22ed2cf1087f5e87feaea2cd2ee095aade")],
    [BigInt("0x17bb700e2dedd658304835e4cdf7c279a228476b99369889c5dc6125ce0d50d1"),
        BigInt("0x0728e2ba2eafcffadd859d2ef9f68f1d2ef395c634ec584b860f8ba147dbe047")]
    ];
const c = [
    BigInt("0x2ff6d96aecac510ff68b71eda8afc58fb03acf019b6cace199510cbef20f765e"),
    BigInt("0x2a8d57dc1bc440a37d0e595dfa408c8b8f2d982ad952e5af2446488934ce3bc2")];
        

const tx = await asiContract.connect(userSigners[2]).proof(a, b, c, BigInt(2));
const receipt = await tx.wait();
console.log("receipt: " , receipt);
/*
wtns.calculate(circuitInput, "./out/anonymous_stand_in_js/anonymous_stand_in.wasm", "./out/foo");
const proof = await groth16.prove("./out/anonymous_stand_in_js/anonymous_stand_in_0001.zkey", "./out/foo");
const a = [
    BigInt("17494513438978055281613103909523570256317814119704507476879838975173981833183"),
    BigInt("3866860310440882772901345560369884380010831129464163073223518441412777483783")];
const b = [
    [BigInt("2054272576349079827750711306048563197450505900028942924320741781016036108554"),
     BigInt("649837212563482933877634047600118360496887218875125593183879666171472511769")],
    [BigInt("4364959451343211804266677976661874224951718929747763002970345576665893609920"),
     BigInt("14431837816838911728862506563401058013692085254609875966711130162675085069442")]
    ];
const c = [
    BigInt("17060584413390629452984938681094336475933534476346496979690576800108830456587"),
    BigInt("26097403303359905897161213567524075386359847463644972700923938046940975946")];
    
console.log("%j", proof);
console.log("bye");

const tx = await asiContract.connect(userSigners[2]).proof(a, b, c, BigInt(2));
const receipt = await tx.wait();
console.log("receipt: " , receipt);
*/