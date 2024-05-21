#!/bin/bash
#
# Name: az_get_vm_Linux.sh
#
# check VM list from AZ CLI
#
export MONITOR_DIR=/BD/Monitor
export BASEDIR=$(dirname $0)
source ~/.proxy

export ACCT=$(az account show -o tsv|awk '{print $4}')

vmfile=${MONITOR_DIR}/AZ_nodeslist_$(hostname)_${ACCT}.lst
touch $vmfile
az vm list --query "[?storageProfile.osDisk.osType=='Linux'].{ID:id}" --output tsv 2> /dev/null |sort -u >> ${vmfile}_new

mv ${vmfile} ${vmfile}_`date +%Y%m%d_%H%M%S`
mv ${vmfile}_new ${vmfile}

ls -ld ${vmfile}
