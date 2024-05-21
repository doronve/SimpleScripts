#!/bin/bash
#
# Name: cd_get_all_hosts.sh
#
# Description: get all CouchBase hosts
#
# Flow: run on all existing hosts and search for /opt/couchbase/VERSION.txt
#
#

MONITOR_DIR=/BD/Monitor
export BASEDIR=$(dirname $0)
remoteUser=$(bash ${BASEDIR}/../GEN/setRemoteUserName.sh)

cmd="cat /opt/couchbase/VERSION.txt"

logdir=/tmp/Logs_cb_`date +%Y%m%d_%H%M%S`
mkdir -p $logdir

for host in `bash GEN/get_hosts_list.sh`
do
  nohup timeout 10 ssh -o ConnectTimeout=3 ${remoteUser}@${host} "$cmd" > $logdir/log_$host.out 2> $logdir/log_$host.err &
done
wait

tmpfile=${MONITOR_DIR}/cb_`date +%Y%m%d_%H%M%S`
rm -f $logdir/*err
for f in $logdir/*out
do
  [[ ! -s $f ]] && rm -f $f
done
ls -d $logdir/log*out | sed 's/.out//' | sed 's!'$logdir'/log_!!' > $tmpfile
mv ${MONITOR_DIR}/CB_Hosts_$(hostname).lst ${MONITOR_DIR}/CB_Hosts_$(hostname).lst_`date +%Y%m%d_%H%M%S`
mv $tmpfile ${MONITOR_DIR}/CB_Hosts_$(hostname).lst
sed -i 's/......KUKU.com//g' ${MONITOR_DIR}/CB_Hosts_$(hostname).lst
for host in `cat ${MONITOR_DIR}/CB_Hosts_$(hostname).lst`
do
  propfile=/BD/Monitor/${host}_properties.sh
  touch $propfile
  sed -i '/CBVERSION/d' $propfile
  echo "export CBVERSION=`cat $logdir/log_$host.out`" >> $propfile
done
sed -i 's/......KUKU.com//g' ${MONITOR_DIR}/CB_Hosts_$(hostname).lst

bash GEN/convert_ip_to_hostname.sh ${MONITOR_DIR}/CB_Hosts_$(hostname).lst

rm -rf $logdir
