#!/usr/bin/env bash
CIRCUIT=anonymous_stand_in

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASE_DIR=${SCRIPT_DIR}
OUT_DIR=${BASE_DIR}/out

PTAU=${OUT_DIR}/powersOfTau28_hez_final_12.ptau
if [ ! -f "${PTAU}" ]
then
    curl https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_12.ptau > "${PTAU}"
fi

circom ${BASE_DIR}/src/${CIRCUIT}.circom --r1cs --wasm --sym --c -o ${OUT_DIR}

cd ${OUT_DIR}/${CIRCUIT}_js
npx snarkjs groth16 setup ${OUT_DIR}/${CIRCUIT}.r1cs ${PTAU} ${CIRCUIT}_0000.zkey
echo "blah blah" | npx snarkjs zkey contribute ${CIRCUIT}_0000.zkey ${CIRCUIT}_0001.zkey --name="1st Contributor Name" -v
npx snarkjs zkey export verificationkey ${CIRCUIT}_0001.zkey verification_key.json


npx snarkjs zkey export solidityverifier ${CIRCUIT}_0001.zkey ${CIRCUIT}_verifier.sol
cat ${CIRCUIT}_verifier.sol | sed 's/pragma solidity ^0.6.11/pragma solidity ^0.8.13/' > ${CIRCUIT}_generated_verifier.sol
