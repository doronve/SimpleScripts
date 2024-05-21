#!/bin/bash

source params.sh

az ml workspace create --resource-group ${GROUPNAME}                                                                                                                      \
                       --name                 ${AMLNAME}                                                                                                                  \
                       --application-insights "/subscriptions/${SUBSCRIPTION}/resourceGroups/GROUP/providers/Microsoft.insights/components/azuremlappinsights"       \
                       --container-registry   "/subscriptions/${SUBSCRIPTION}/resourceGroups/${GROUPNAME}/providers/Microsoft.ContainerRegistry/registries/${ACRNAME}"    \
                       --description          "Test installation"                                                                                                         \
                       --display-name         ${AMLDISPLAY}                                                                                                               \
                       --image-build-compute  "mem-cluster"                                                                                                               \
                       --location             ${LOCATION}                                                                                                                 \
                       --tags                 ${TAGS}                                                                                                                     \
                       --keyvault            "${KVID}"                                                                                                                    \
                       --storage-account      "/subscriptions/${SUBSCRIPTION}/resourceGroups/${GROUPNAME}/providers/Microsoft.Storage/storageAccounts/${STANAME}"         \



exit
az ml workspace create Y --resource-group
                       Y [--application-insights]
                       Y [--container-registry]
                       Y [--description]
                       Y [--display-name]
                       N [--enable-data-isolation]
                       N [--file]
                       Y [--image-build-compute]
                       Y [--key-vault]
                       Y [--location]
                       N [--managed-network]
                       Y [--name]
                       N [--no-wait]
                       N [--primary-user-assigned-identity]
                       N [--public-network-access]
                       N [--set]
                       Y [--storage-account]
                       Y [--tags]
                       N [--update-dependent-resources]
