#!/bin/bash
source params.sh

echo "\$schema: https://azuremlschemas.azureedge.net/latest/workspace.schema.json
name: ${AMLNAME}
location: ${LOCATION}
display_name: ${AMLNAME}
description: This AML Created by Azure CLI Scripts.
storage_account: ${STAID}
container_registry: ${ACRID}
key_vault: ${KVID}
application_insights: ${APPID}
tags:
  purpose: demonstration
" > amlsw.yaml

az ml workspace create --file amlsw.yaml --resource-group ${GROUPNAME}

