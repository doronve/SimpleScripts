#!/bin/bash

source params.sh

az storage account create --name                           ${STANAME}                           \
                          --resource-group                 ${GROUPNAME}                         \
                          --location                       ${LOCATION}                          \
                          --access-tier                    Hot                                  \
                          --account-type                   "Microsoft.Storage/storageAccounts"  \
                          --allow-blob-public-access       false                                \
                          --allow-cross-tenant-replication true                                 \
                          --bypass                         AzureServices                        \
                          --default-action                 Deny                                 \
                          --dns-endpoint-type              Standard                             \
                          --https-only                     true                                 \
                          --kind                           StorageV2                            \
                          --min-tls-version                TLS1_2                               \
                          --public-network-access          Enabled                              \
                          --sku                            ${STASKU}                            \
                          --subnet                         ${SUBNETID}                          \
                          --tags                           ${TAGS}                              \



exit
Y - defined
N - not defined
D - Default Values
az storage account create Y --name
                          Y --resource-group
                          Y [--access-tier {Cool, Hot, Premium}]
                          Y [--account-type]
                          N [--action]
                          N [--allow-append {false, true}]
                          Y [--allow-blob-public-access {false, true}]
                          Y [--allow-cross-tenant-replication {false, true}]
                          D [--allow-shared-key-access {false, true}]
                          N [--assign-identity]
                          N [--azure-storage-sid]
                          Y [--bypass {AzureServices, Logging, Metrics, None}]
                          N [--custom-domain]
                          Y [--default-action {Allow, Deny}]
                          N [--default-share-permission {None, StorageFileDataSmbShareContributor, StorageFileDataSmbShareElevatedContributor, StorageFileDataSmbShareReader}]
                          Y [--dns-endpoint-type {AzureDnsZone, Standard}]
                          N [--domain-guid]
                          N [--domain-name]
                          N [--domain-sid]
                          N [--edge-zone]
                          N [--enable-alw {false, true}]
                          N [--enable-files-aadds {false, true}]
                          N [--enable-files-aadkerb {false, true}]
                          N [--enable-files-adds {false, true}]
                          N [--enable-hierarchical-namespace {false, true}]
                          N [--enable-large-file-share]
                          N [--enable-local-user {false, true}]
                          N [--enable-nfs-v3 {false, true}]
                          N [--enable-sftp {false, true}]
                          N [--encryption-key-name]
                          N [--encryption-key-source {Microsoft.Keyvault, Microsoft.Storage}]
                          N [--encryption-key-type-for-queue {Account, Service}]
                          N [--encryption-key-type-for-table {Account, Service}]
                          N [--encryption-key-vault]
                          N [--encryption-key-version]
                          N [--encryption-services {blob, file, queue, table}]
                          N [--forest-name]
                          Y [--https-only {false, true}]
                          N [--identity-type {None, SystemAssigned, SystemAssigned,UserAssigned, UserAssigned}]
                          N [--immutability-period]
                          N [--immutability-state {Disabled, Locked, Unlocked}]
                          N [--key-exp-days]
                          N [--key-vault-federated-client-id]
                          N [--key-vault-user-identity-id]
                          Y [--kind {BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2}]
                          Y [--location]
                          Y [--min-tls-version {TLS1_0, TLS1_1, TLS1_2}]
                          N [--net-bios-domain-name]
                          Y [--public-network-access {Disabled, Enabled}]
                          [--publish-internet-endpoints {false, true}]
                          [--publish-microsoft-endpoints {false, true}]
                          D [--require-infrastructure-encryption {false, true}]
                          N [--routing-choice {InternetRouting, MicrosoftRouting}]
                          N [--sam-account-name]
                          N [--sas-exp]
                          Y [--sku {Premium_LRS, Premium_ZRS, Standard_GRS, Standard_GZRS, Standard_LRS, Standard_RAGRS, Standard_RAGZRS, Standard_ZRS}]
                          Y [--subnet]
                          Y [--tags]
                          N [--user-identity-id]
                          N [--vnet-name]




