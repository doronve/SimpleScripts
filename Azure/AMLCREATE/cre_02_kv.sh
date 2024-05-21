#!/bin/bash

source params.sh

az keyvault create --resource-group ${GROUPNAME}           \
                   --name ${KVNAME}                        \
                   --location ${LOCATION}                  \
                   --bypass AzureServices                  \
                   --default-action Deny                   \
                   --enable-rbac-authorization false       \
                   --enabled-for-deployment true           \
                   --enabled-for-disk-encryption true      \
                   --enabled-for-template-deployment true  \
                   --network-acls-ips ${KVNACLIP}          \
                   --public-network-access Disabled        \
                   --retention-days 90                     \
                   --sku ${KVSKU}                          \
                   --tags ${TAGS}                          \


exit
az keyvault create --resource-group
                   [--administrators]
                   [--bypass {AzureServices, None}]
                   [--default-action {Allow, Deny}]
                   [--enable-purge-protection {false, true}]
                   [--enable-rbac-authorization {false, true}]
                   [--enabled-for-deployment {false, true}]
                   [--enabled-for-disk-encryption {false, true}]
                   [--enabled-for-template-deployment {false, true}]
                   [--hsm-name]
                   [--location]
                   [--name]
                   [--network-acls]
                   [--network-acls-ips]
                   [--network-acls-vnets]
                   [--no-self-perms {false, true}]
                   [--no-wait]
                   [--public-network-access {Disabled, Enabled}]
                   [--retention-days]
                   [--sku]
                   [--tags]

