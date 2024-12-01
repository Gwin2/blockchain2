#!/bin/bash

if ! command -v myth &> /dev/null
then
    echo "Mythril could not be found, please install it first."
    exit
fi

for contract in $(find ./artifacts/contracts -name "*.json"); do
    echo "Analyzing $contract"
    myth analyze $contract
    done
