#!/usr/bin/env bash

THE_USER=0x15d34aaf54267db7d7c367839aaf71a00a2c6a65

// The first 5 addresses provided by anvil.
cat > out/users.txt <<EOF
0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
0x70997970c51812dc3a010c7d01b50e0d17dc79c8
0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc
0x90f79bf6eb2c4f870365e785982e1f101e93b906
0x15d34aaf54267db7d7c367839aaf71a00a2c6a65
EOF

echo "0xCafeBabe" > out/secret.txt

# poseidon([0x15d34aaf54267db7d7c367839aaf71a00a2c6a65, 0xCafeBabe]) =
# 14992967248067620736906915151099623099783214469663224091377866644517376473097

cat > out/questions.txt <<EOF
123
14992967248067620736906915151099623099783214469663224091377866644517376473097
456
789
EOF

time npx tsc --outDir out src/GenerateInput.ts && node out/GenerateInput.js ${THE_USER} out/secret.txt out/users.txt out/questions.txt | tee out/GenerateInput.txt

tail -n 1 out/GenerateInput.txt > out/input.json
