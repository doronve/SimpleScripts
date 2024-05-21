#!/bin/bash
#
# Name: scylla_get_all_hosts.sh
#
# Description: get all Scylla hosts
#
# Flow: run on all existing hosts and search in /etc/scylla
#
#

MONITOR_DIR=/BD/Monitor
export BASEDIR=$(dirname $0)

cmd="ls -ld /etc/scylla*"

logdir=/tmp/Logs_scy_$(date +%Y%m%d_%H%M%S)
mkdir -p $logdir

for host in $(bash ${BASEDIR}/../GEN/get_hosts_list.sh)
do
  nohup ssh -o ConnectTimeout=10 $host "$cmd" > $logdir/log_$host.out 2> $logdir/log_$host.err &
done
wait

tmpfile=${MONITOR_DIR}/scy_$(date +%Y%m%d_%H%M%S)
cd $logdir
grep -l scylla *out | sed 's/.out//' | sed 's/log_//g' | sort -u > $tmpfile
cd
mv ${MONITOR_DIR}/SCY_Hosts_$(hostname).lst ${MONITOR_DIR}/SCY_Hosts_$(hostname).lst_$(date +%Y%m%d_%H%M%S)
mv $tmpfile ${MONITOR_DIR}/SCY_Hosts_$(hostname).lst
sed -i 's/......KUKU.com//g' ${MONITOR_DIR}/SCY_Hosts_$(hostname).lst

#bash ${BASEDIR}/../GEN/convert_ip_to_hostname.sh ${MONITOR_DIR}/SCY_Hosts_$(hostname).lst

rm -rf $logdir
