#!/usr/bin/env bash
time npx tsc --outDir out src/MerkleProof.ts && node out/MerkleProof.js 10 <(echo -e '1\n2\n0xA')
