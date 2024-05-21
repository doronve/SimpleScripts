#!/bin/bash


source params.sh

az acr create --name               ${ACRNAME}    \
              --resource-group     ${GROUPNAME}  \
              --sku                Premium       \
              --location           ${LOCATION}   \
              --admin-enabled      true          \
              --default-action     Deny          \
              --tags               ${TAGS}       \


exit
az acr create Y --name
              Y --resource-group
              Y --sku {Basic, Premium, Standard}
              Y [--admin-enabled {false, true}]
              N [--allow-exports {false, true}]
              N [--allow-trusted-services {false, true}]
              Y [--default-action {Allow, Deny}]
              N [--identity]
              N [--key-encryption-key]
              Y [--location]
              N [--public-network-enabled {false, true}]
              Y [--tags]
              N [--workspace]
              N [--zone-redundancy {Disabled, Enabled}]


