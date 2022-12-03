import { ethers } from "ethers"

import { getTree } from "./asi_proof.js";

class SessionInfo {
    static random() {
        const a = new BigUint64Array(4);
        return (a[0] << 24n) | (a[1] << 16n) | (a[2] << 8n) | a[3];
    }
    constructor(sessionId = SessionInfo.random()) {
        // don't have to be a strong one
        this.sessionId = sessionId;
        this.idToAddr = new Map();
    }
    // insertion order
    add(id, addr) {
        this.idToAddr.set(id, ethers.utils.getAddress(addr));
    }
    stringify() {
        // TODO: getAddress
        const h = (bi) => "0x" + bi.toString(16);
        var s = "";
        var i = 0;
        var last = this.idToAddr.size - 1;
        for (const [id, addr] of this.idToAddr) {
            s += "        [" + JSON.stringify(id) + ", " + JSON.stringify(addr) + "]" + (i == last ? "" : ",") + "\n";
            i++;
        }
        const root = h(getTree(this.idToAddr.values()).root);
        return "{\n" +
            `    "sessionId": "${h(this.sessionId)}",\n` +
            `    "users": [\n` +
                     s +
            `    ],\n` +
            `    "root": "${root}"\n` +
            "}";
    }
}

var si = new SessionInfo();
si.add("B", "0x70997970c51812dc3a010c7d01b50e0d17dc79c8");
si.add("C", "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc");
si.add("A", "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");
console.log(si.stringify());
var j = JSON.parse(si.stringify());
console.log(JSON.stringify(j, undefined, 4));