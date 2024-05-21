#!/usr/bin/bash
#
# Create AML Compute Cluster
#

source params.sh

az ml compute create --resource-group              ${GROUPNAME}                           \
                     --workspace-name              ${AMLNAME}                             \
                     --location                    ${LOCATION}                            \
                     --admin-password              "PASSWORD"                         \
                     --admin-username              "KUKU"                               \
                     --description                 "Compute-instance for ${AMLNAME}"      \
                     --enable-node-public-ip       false                                  \
                     --ssh-public-access-enabled   false                                  \
                     --max-instances               2                                      \
                     --min-instances               1                                      \
                     --name                        cc-${AMLNAME}-1                        \
                     --size                        STANDARD_DS3_V2                        \
                     --subnet                      ${SUBNETID}                            \
                     --tags                        ${TAGS}                                \
                     --type                        computeinstance                        \

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


[
