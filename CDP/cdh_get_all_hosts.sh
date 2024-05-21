#!/bin/bash
#
# Name: cdh_get_all_hosts.sh
#
# Description: get all Cloudera Manager hosts
#
# Flow: run on all existing hosts and search in /etc/cloudera-scm-agent/config.ini
#
#

MONITOR_DIR=/BD/Monitor
export BASEDIR=$(dirname $0)
remoteUser=$(bash ${BASEDIR}/../GEN/setRemoteUserName.sh)

cmd="awk -F= '/server_host/{print \$2}' /etc/cloudera-scm-agent/config.ini"

logdir=/tmp/Logs_cdh_`date +%Y%m%d_%H%M%S`
mkdir -p $logdir

for host in `bash GEN/get_hosts_list.sh`
do
  nohup timeout 10 ssh -o ConnectTimeout=3 ${remoteUser}@${host} "$cmd" > $logdir/log_$host.out 2> $logdir/log_$host.err &
done
wait

tmpfile=${MONITOR_DIR}/cdh_`date +%Y%m%d_%H%M%S`
sort -u $logdir/log*out > $tmpfile
mv ${MONITOR_DIR}/CDH_Hosts_$(hostname).lst ${MONITOR_DIR}/CDH_Hosts_$(hostname).lst_`date +%Y%m%d_%H%M%S`
mv $tmpfile ${MONITOR_DIR}/CDH_Hosts_$(hostname).lst
sed -i 's/......KUKU.com//g' ${MONITOR_DIR}/CDH_Hosts_$(hostname).lst
bash GEN/convert_ip_to_hostname.sh ${MONITOR_DIR}/CDH_Hosts_$(hostname).lst

rm -rf $logdir
