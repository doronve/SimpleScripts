#!/usr/bin/bash
#
# Create AML Compute Cluster
#

source params.sh

echo "\$schema: https://azuremlschemas.azureedge.net/latest/computeInstance.schema.json
type: computeinstance
name: $(echo ci-${AMLNAME}-1 | sed 's/-//g')
description: Compute-instance for ${AMLNAME}
size: STANDARD_DS3_v2
network_settings:
  subnet: ${SUBNETID}
" > amlswcc.yaml

az ml compute create --file amlswcc.yaml --resource-group ${GROUPNAME} -w ${AMLNAME}




exit

az ml compute create --resource-group
                     --workspace-name
                     Y [--admin-password]
                     Y [--admin-username]
                     Y [--description]
                     Y [--enable-node-public-ip]
                     N [--file]
                     N [--identity-type]
                     N [--idle-time-before-scale-down]
                     Y [--location]
                     Y [--max-instances]
                     Y [--min-instances]
                     Y [--name]
                     N [--no-wait]
                     N [--set]
                     Y [--size]
                     N [--ssh-key-value]
                     Y [--ssh-public-access-enabled]
                     Y [--subnet]
                     Y [--tags]
                     N [--tier]
                     Y [--type]
                     N [--user-assigned-identities]
                     N [--user-object-id]
                     N [--user-tenant-id]
                     N [--vnet-name]

