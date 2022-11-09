#!/usr/bin/env bash
CIRCUIT=anonymous_stand_in

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASE_DIR=${SCRIPT_DIR}
OUT_DIR=${BASE_DIR}/out

PTAU=${OUT_DIR}/powersOfTau28_hez_final_16.ptau
if [ ! -f "${PTAU}" ]
then
    curl https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_16.ptau > "${PTAU}" 
fi

circom ${BASE_DIR}/src/${CIRCUIT}.circom --r1cs --wasm --sym --c -o ${OUT_DIR}

cd ${OUT_DIR}/${CIRCUIT}_js
npx snarkjs groth16 setup ${OUT_DIR}/${CIRCUIT}.r1cs ${PTAU} ${CIRCUIT}_0000.zkey
echo "blah blah" | npx snarkjs zkey contribute ${CIRCUIT}_0000.zkey ${CIRCUIT}_0001.zkey --name="1st Contributor Name" -v
npx snarkjs zkey export verificationkey ${CIRCUIT}_0001.zkey verification_key.json

cat > input.json <<EOF
{
    "leaf": "3",
    "pathIndices": ["0", "1", "0", "0", "0"],
    "siblings": [
        "0",
        "7853200120776062878684798364095072458815029376092732009249414926327459813530",
        "7423237065226347324353380772367382631490014989348495481811164164159255474657",
        "11286972368698509976183087595462810875513684078608517520839298933882497716792",
        "3607627140608796879659380071776844901612302623152076817094415224584923813162"
     ]
}
EOF


node generate_witness.js ${CIRCUIT}.wasm input.json witness.wtns

npx snarkjs groth16 prove ${CIRCUIT}_0001.zkey witness.wtns proof.json public.json

npx snarkjs groth16 verify verification_key.json public.json proof.json
