import { poseidon } from "circomlibjs"; // v0.0.8
import { argv } from 'process';

console.log(poseidon([argv[2], argv[3]]).toString());
