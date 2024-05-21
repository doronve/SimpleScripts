#!/bin/bash
#
# Name: psql_get_all_hosts.sh
#
# Description: get all Psql hosts
#
# Flow: run on all existing hosts and search rpm for psql
#
#

MONITOR_DIR=/BD/Monitor
export BASEDIR=$(dirname $0)

cmd='export PGPASSWORD=postgres && psql -h $(hostname) -U postgres -w -c "\\l"'
cmd='which psql'

logdir=/tmp/Logs_psql_$(date +%Y%m%d_%H%M%S)
mkdir -p $logdir

for host in $(bash ${BASEDIR}/../GEN/get_hosts_list.sh)
do
  nohup ssh -o ConnectTimeout=3 $host "$cmd" > $logdir/log_$host.out 2> $logdir/log_$host.err &
done
wait
#ls -l $logdir
sed -i '/no psql in/d' ${logdir}/*

tmpfile=${MONITOR_DIR}/psql_$(date +%Y%m%d_%H%M%S)
cd $logdir
#grep -l  "List of databases" *out | sed 's/.out//' | sed 's/log_//g' | sort -u > $tmpfile
grep -l  "psql" *out | sed 's/.out//' | sed 's/log_//g' | sort -u > $tmpfile
cd
mv ${MONITOR_DIR}/PSQL_Hosts_$(hostname).lst ${MONITOR_DIR}/PSQL_Hosts_$(hostname).lst_$(date +%Y%m%d_%H%M%S)
mv $tmpfile ${MONITOR_DIR}/PSQL_Hosts_$(hostname).lst
sed -i 's/......KUKU.com//g' ${MONITOR_DIR}/PSQL_Hosts_$(hostname).lst

#bash ${BASEDIR}/GEN/convert_ip_to_hostname.sh ${MONITOR_DIR}/PSQL_Hosts_$(hostname).lst

rm -rf $logdir
