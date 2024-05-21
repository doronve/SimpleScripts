#!/usr/bin/bash
#
# Create AML Compute Cluster
#

source params.sh

echo "\$schema: https://azuremlschemas.azureedge.net/latest/amlCompute.schema.json
type: amlcompute
name: cc-${AMLNAME}-1
location: ${LOCATION}
description: Compute-Cluster for ${AMLNAME}
size: STANDARD_DS3_v2
min_instances: 1
max_instances: 2
ssh_settings:
  admin_username: KUKU
  admin_password: PASSWORD
network_settings:
  subnet: ${SUBNETID}
" > amlswcc.yaml

az ml compute create --file amlswcc.yaml --resource-group ${GROUPNAME} -w ${AMLNAME}

#enable_node_public_ip: false


