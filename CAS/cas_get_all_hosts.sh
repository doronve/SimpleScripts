#!/bin/bash
#
# Name: cas_get_all_hosts.sh
#
# Description: get all Cassandra hosts
#
# Flow: run on all existing hosts and search rpm for cassandra
#
#

MONITOR_DIR=/BD/Monitor
export BASEDIR=$(dirname $0)
remoteUser=$(bash ${BASEDIR}/../GEN/setRemoteUserName.sh)

cmd='rpm -qa'

logdir=/tmp/Logs_cas_$(date +%Y%m%d_%H%M%S)
mkdir -p $logdir

for host in $(bash GEN/get_hosts_list.sh)
do
  nohup ssh -o ConnectTimeout=3 ${remoteUser}@${host} "$cmd" > $logdir/log_$host.out 2> $logdir/log_$host.err &
done
wait

tmpfile=${MONITOR_DIR}/cas_$(date +%Y%m%d_%H%M%S)
cd $logdir
grep -l  "cassandra" *out | sed 's/.out//' | sed 's/log_//g' | sort -u > $tmpfile
cd -
mv ${MONITOR_DIR}/CAS_Hosts.lst ${MONITOR_DIR}/CAS_Hosts.lst_$(date +%Y%m%d_%H%M%S)
mv $tmpfile ${MONITOR_DIR}/CAS_Hosts.lst
sed -i 's/......KUKU.com//g' ${MONITOR_DIR}/CAS_Hosts.lst

bash GEN/convert_ip_to_hostname.sh ${MONITOR_DIR}/CAS_Hosts.lst

rm -rf $logdir
