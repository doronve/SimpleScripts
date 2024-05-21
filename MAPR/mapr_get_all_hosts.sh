#!/bin/bash
#
# Name: mapr_get_all_hosts.sh
#
# Description: get all MapR hosts
#
# Flow: run on all existing hosts and search in /opt/mapr/hive/*/conf/hiveserver2-site.xml
#
# TODO: find a better way than hiveserver2 file
#

MONITOR_DIR=/BD/Monitor
export BASEDIR=$(dirname $0)
remoteUser=$(bash ${BASEDIR}/../GEN/setRemoteUserName.sh)

cmd="awk -F: '/jdbc:mysql/{print $3}' /opt/mapr/hive/*/conf/hiveserver2-site.xml|sed 's/\///g'"
cmd="cat /opt/mapr/zookeeper/zookeeper*/conf/zoo.cfg  | grep server.0= | sed 's/server.0=//' | sed 's/:2888:3888//'"

logdir=/tmp/Logs_MAPR_`date +%Y%m%d_%H%M%S`
mkdir -p $logdir
for host in `bash GEN/get_hosts_list.sh`
do
  nohup timeout 10 ssh -o ConnectTimeout=3 ${remoteUser}@${host} "$cmd" > $logdir/log_$host.out 2> $logdir/log_$host.err &
done
wait
tmpfile=${MONITOR_DIR}/mapr_`date +%Y%m%d_%H%M%S`
sort -u $logdir/log*out > $tmpfile
mv ${MONITOR_DIR}/MAPR_Hosts_$(hostname).lst ${MONITOR_DIR}/MAPR_Hosts_$(hostname).lst_`date +%Y%m%d_%H%M%S`
mv $tmpfile ${MONITOR_DIR}/MAPR_Hosts_$(hostname).lst
sed -i 's/<value>jdbc:mysql://'    ${MONITOR_DIR}/MAPR_Hosts_$(hostname).lst
sed -i 's/:3306metastore<value>//' ${MONITOR_DIR}/MAPR_Hosts_$(hostname).lst
sed -i 's/......KUKU.com//g'     ${MONITOR_DIR}/MAPR_Hosts_$(hostname).lst

for host in `cat ${MONITOR_DIR}/MAPR_Hosts_$(hostname).lst`
do
  bash MAPR/get_zookeeper_list.sh $host
done
bash GEN/convert_ip_to_hostname.sh ${MONITOR_DIR}/MAPR_Hosts_$(hostname).lst

rm -rf $logdir
