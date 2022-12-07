import { ethers } from "ethers"
import { Proof } from "./asi_proof.js";

class SessionInfo {
    static random() {
        return ethers.BigNumber.from(ethers.utils.randomBytes(32)).toBigInt();
    }
    // sessionId doesn't have to be a strong-random one
    constructor(sessionId = SessionInfo.random()) {
        this.sessionId = BigInt(sessionId);
        this.idToAddr = new Map();
    }
    // insertion order (by Map())
    add(id, addr) {
        this.idToAddr.set(id, ethers.utils.getAddress(addr));
    }
    // address hex strings in insertion order
    get userAddresses() {
        return [...this.idToAddr.values()];
    }
    // BigInt
    get userTreeRoot() {
        return Proof.getTree(this.idToAddr.values()).root;
    }
    stringify() {
        const h = (bi) => "0x" + bi.toString(16);
        const o = {
            sessionId: h(this.sessionId),
            users: [...this.idToAddr.entries()],
            root: h(this.userTreeRoot)
            };
        return JSON.stringify(o, undefined, 4)
            .replaceAll(/^(\s+\[)\n\s+/gm, (match, p1) => p1 + " ")
            .replaceAll(/^(            )"/gm, '          "')
            .replaceAll(/"\n        /g, '" ');
    }
    static parse(s) {
        const json = JSON.parse(s);
        if (!json.sessionId) {
            throw "sessionId should not be empty";
        }
        const si = new SessionInfo(json.sessionId);
        json.users.forEach(([id, addr]) => {
            si.add(id, addr);
        });
        if (json.root && BigInt(json.root) != si.userTreeRoot) {
            throw "root mismatch: " + BigInt(json.root) + " " + si.userTreeRoot;
        }
        return si;
    }
}

export { SessionInfo };

/*
var si = new SessionInfo();
si.add("B", "0x70997970c51812dc3a010c7d01b50e0d17dc79c8");
si.add("C", "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc");
si.add("A", "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");
const s = si.stringify();
console.log(s);

var si2 = SessionInfo.parse(s);
console.log(si2.stringify());
*/