#!/bin/sh
(cd src/asi; rm -fR dist; mkdir dist; npm run build)
npx browserify  -r circomlibjs -r @zk-kit/incremental-merkle-tree -r ethers -r asi > web/bundle.js
