#!/bin/bash

venv=$1
[[ -z "${venv}" ]] && venv=".venv"
source ~/.proxy
python3 -m venv ${venv}

source ${venv}/bin/activate

echo pip install azure-identity azure-keyvault-secrets azure-storage-blob
pip install azure-identity azure-keyvault-secrets azure-storage-blob 2>&1 | grep -v "Requirement already satisfied"
echo status=$?
echo pip install --upgrade pip
pip install --upgrade pip 2>&1 | grep -v "Requirement already satisfied"
echo status=$?

