#!/bin/bash
#
# Name: check_eaas.sh
#
# check VM list from eaas
#
MONITOR_DIR=/BD/Monitor
if [ -f /tmp/check_eaas.lock ]
then
  echo check_eaas is already running
  epid=`cat /tmp/check_eaas.lock`
  ps -fp $epid
  exit 1
fi
echo $$ > /tmp/check_eaas.lock

vmfile=${MONITOR_DIR}/nodeslist_eaas_IL_$(hostname).lst
touch $vmfile

/tccc/adjcc9/PCI_TOOLS/DEV_EAAS/Scripts/PCI_VCO_PRD_GetOrgVMsList_new.py BDA-IL 2> /dev/null |sort -u >> ${vmfile}_new

newlist=`diff ${vmfile} ${vmfile}_new | awk '/>/{print $2}'`
for vm in $newlist
do
  expect GEN/my_copy_id.exp $vm
done

mv ${vmfile} ${vmfile}_`date +%Y%m%d_%H%M%S`
mv ${vmfile}_new ${vmfile}

rm -f /tmp/check_eaas.lock

vmfile=${MONITOR_DIR}/nodeslist_eaas_IND_$(hostname).lst
/tccc/adjcc9/PCI_TOOLS/DEV_EAAS/Scripts/PCI_VCO_PRD_GetOrgVMsList_new_IN.py BDA-IN 2> /dev/null |sort -u >> ${vmfile}_new

sed -i '/template/d' ${vmfile}_new

newlist=`diff ${vmfile} ${vmfile}_new | awk '/>/{print $2}'`
for vm in $newlist
do
  expect GEN/my_copy_id.exp $vm
done

mv ${vmfile} ${vmfile}_`date +%Y%m%d_%H%M%S`
mv ${vmfile}_new ${vmfile}

