#!/bin/env python3
from openai import AzureOpenAI
import os
import argparse

# Create the parser
parser = argparse.ArgumentParser(description="A simple argument parser")

# Add the arguments
parser.add_argument('Param1', metavar='param1', type=str, help='a string parameter')
parser.add_argument('Param2', metavar='param2', type=str, help='a string parameter')

# Parse the arguments
args = parser.parse_args()

print("Param1: ", args.Param1)
print("Param2: ", args.Param2)

msg="openai.PermissionDeniedError: Error code: 403 - {'error': {'code': '403', 'message': 'Access denied due to Virtual Network/Firewall rules.'}}"
#msg="aia-ui-frontend-6fdb7fffd7-sxwr4   0/1     Init:ImagePullBackOff"
#msg='Warning   Unhealthy   Pod/fndsec-pki-operator-5cc9c8784b-nmnr5   Readiness probe failed: Get "https://10.254.20.155:8081/actuator/health": context deadline exceeded'
evt="Im running a python code with AzureOpenAI function, and I get this error. Provide me Possible solutions it:\n"
#system_content="You are a DevOps expert in Kubernetes."
#system_content="You are an Azure Openai expert."
system_content=args.Param1
user_content=evt+args.Param2

client = AzureOpenAI (
    azure_endpoint="AZURE-ENDPOINT",
    api_key="API-KEY",
    api_version="2023-09-15-preview"
)

message_text = [{"role": "system", "content": system_content},
                {"role": "user",   "content": user_content }]

response = client.chat.completions.create(
    model="gpt-35-turbo-0301",
    messages=message_text,
    temperature=1,
    max_tokens=100,
    top_p=0.5,
    frequency_penalty=0,
    presence_penalty=0,
    stop=None)

print(response.choices[0].message.content)

