#!/bin/bash


GROUP=devops-rg
SUBSCRIPTION="SUBSCRIPTION"
VNET=VNET
SUBNET=SUBNET

az group create --resource-group $GROUP -l northeurope
az vm create -n devops-win-1 -g $GROUP -l northeurope \
   --image MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest \
   --priority Regular \
   --size Standard_D2s_v3 \
   --authentication-type password \
   --admin-username KUKU \
   --admin-password PASSWOD \
   --subnet /subscriptions/${SUBSCRIPTION}/resourceGroups/GROUP/providers/Microsoft.Network/virtualNetworks/${VNET}/subnets/${SUBNET} \
   --license-type Windows_Server


exit
   --public-ip-address "" \
   --os-disk-size-gb 100 \

