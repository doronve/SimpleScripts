#!/bin/bash

logfile=$(mktemp)
bash -x cre_00_all.sh -n myname \
                   -i /subscriptions/XxXxXxXx-XxXx-XxXx-XxXx-XxXxXxXxXxXx/resourceGroups/my-group/providers/Microsoft.Network/virtualNetworks/MyVnet/subnets/MySubnet \
                   -k /subscriptions/XxXxXxXx-XxXx-XxXx-XxXx-XxXxXxXxXxXx/resourceGroups/my-group/providers/Microsoft.KeyVault/vaults/MyKeyVault                      \
                   -s /subscriptions/XxXxXxXx-XxXx-XxXx-XxXx-XxXxXxXxXxXx/resourceGroups/my-group/providers/Microsoft.Storage/storageAccounts/MyStorage               \
                   -a /subscriptions/XxXxXxXx-XxXx-XxXx-XxXx-XxXxXxXxXxXx/resourceGroups/my-group/providers/Microsoft.ContainerRegistry/registries/MyAcr              \
                   -m /subscriptions/XxXxXxXx-XxXx-XxXx-XxXx-XxXxXxXxXxXx/resourceGroups/my-group/providers/Microsoft.insights/components/MyAppInsight                \
                   -l northeurope 2>&1 | tee ${logfile}

ls -ld ${logfile}
