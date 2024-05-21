#!/bin/bash


function Usage()
{
  echo "$0 <PENAME> <privateLinkServiceId>"
  exit 1
}

PENAME=$1
[[ -z "${PENAME}" ]] && Usage
privateLinkServiceId=$2
[[ -z "${privateLinkServiceId}" ]] && Usage

source params.sh 

az network private-endpoint create --connection-name                    ${PENAME}-PrivateEndpoint \
                                   --name                               ${PENAME}-pe              \
                                   --private-connection-resource-id     ${privateLinkServiceId}   \
                                   --resource-group                     ${GROUPNAME}              \
                                   --subnet                             ${SUBNETID}               \
                                   --group-id                           ${GROUPNAME}              \
                                   --location                           ${LOCATION}               \
                                   --tags                               ${TAGS}                   \


exit
az network private-endpoint create --connection-name
                                   --name
                                   --private-connection-resource-id
                                   --resource-group
                                   --subnet
                                   N [--asg]
                                   N [--edge-zone]
                                   Y [--group-id]
                                   N [--ip-config]
                                   Y [--location]
                                   N [--manual-request {0, 1, f, false, n, no, t, true, y, yes}]
                                   N [--nic-name]
                                   N [--no-wait {0, 1, f, false, n, no, t, true, y, yes}]
                                   N [--request-message]
                                   Y [--tags]
                                   N [--vnet-name]



exit
az network private-endpoint create -g MyResourceGroup -n MyPE --vnet-name MyVnetName --subnet MySubnet --private-connection-resource-id "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroup/providers/Microsoft.Network/privateLinkServices/MyPLS" --connection-name tttt -l centralus

