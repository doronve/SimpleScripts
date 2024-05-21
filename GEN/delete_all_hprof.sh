#!/bin/bash
#
# Name: delete_all_hprof.sh
#
# Description: check which server has hprof dump files and delete them
#


cmd="ls -d /tmp/*hprof /opt/KUKU/external/cloudera/*/heap/*hprof"

logdir=$(mktemp -d /tmp/Logs_hprof_XXXXX)
mkdir -p $logdir
for host in $(bash GEN/get_hosts_list.sh )
do
  nohup timeout 10 ssh -o ConnectTimeout=3 $host "$cmd" > $logdir/$host.out 2> $logdir/$host.err &
done
wait

grep -l "hprof" $logdir/*.out >> $logdir/has_hprof

if [ -s $logdir/has_hprof ]
then
  echo "the followng servers has hprof files: $(cat $logdir/has_hprof)" | mailx -s "hprof files" doronve@KUKU.com
  echo "the followng servers has hprof files: $(cat $logdir/has_hprof)" | mailx -s "hprof files" didevops@int.KUKU.com
fi

cmd="rm -f /tmp/*hprof /opt/KUKU/external/cloudera/*/heap/*hprof"
for host in $(bash GEN/get_hosts_list.sh )
do
  nohup timeout 10 ssh -o ConnectTimeout=3 $host "$cmd" > $logdir/$host.out 2> $logdir/$host.err &
done
wait

rm -rf  $logdir

echo ""
