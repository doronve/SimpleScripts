#!/usr/bin/bash

BASEDIR=$(dirname $0)
source ~/.proxy
export OPENAI_API_KEY=OPENAI_API_KEY
python3 ${BASEDIR}/ai.py \
  ""You are a DevOps expert in Kubernetes."" \
  "openai.PermissionDeniedError: Error code: 403 - {'error': {'code': '403', 'message': 'Access denied due to Virtual Network/Firewall rules.'}}"
