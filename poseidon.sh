#!/bin/sh
npx tsc --outDir out src/Poseidon.ts && node out/Poseidon.js "$1" "$2"
