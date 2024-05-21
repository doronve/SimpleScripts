#!/bin/bash
#
# Name: k8s_get_all_hosts.sh
#
# Description: get all Cloudera Manager hosts
#
# Flow: run on all existing hosts and search in /etc/cloudera-scm-agent/config.ini
#

export BASEDIR=$(dirname $0)
remoteUser=$(bash ${BASEDIR}/../GEN/setRemoteUserName.sh)

MONITOR_DIR=/BD/Monitor

cmd="kubectl get nodes"

logdir=/tmp/Logs_k8s_$(date +%Y%m%d_%H%M%S)
mkdir -p $logdir

for host in $(bash GEN/get_hosts_list.sh | grep -v aia-oc-client | grep -v aia-jenkins | grep -v aia-aws-client |grep -v ilmtxbda73)
do
  nohup timeout 10 ssh -o ConnectTimeout=3 ${remoteUser}@${host} "$cmd" > $logdir/log_$host.out 2> $logdir/log_$host.err &
done
wait

tmpfile=$(mktemp)
awk '/master/{print $1}' $logdir/log*out | sort -u > $tmpfile
mv ${MONITOR_DIR}/K8S_Hosts_$(hostname).lst ${MONITOR_DIR}/K8S_Hosts_$(hostname).lst_$(date +%Y%m%d_%H%M%S)
mv $tmpfile ${MONITOR_DIR}/K8S_Hosts_$(hostname).lst
sed -i 's/......KUKU.com//g' ${MONITOR_DIR}/K8S_Hosts_$(hostname).lst
bash GEN/convert_ip_to_hostname.sh ${MONITOR_DIR}/K8S_Hosts_$(hostname).lst

rm -rf $logdir
