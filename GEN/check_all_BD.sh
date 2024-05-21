#!/bin/bash
#
# Name: check_all_BD.sh
#
# Description: check which server is missing /BD
#


cmd="df -P /BD"

logdir=$(mktemp -d /tmp/Logs_BD_XXXXX)
mkdir -p $logdir
for host in $(bash GEN/get_hosts_list.sh )
do
  nohup timeout 10 ssh -o ConnectTimeout=3 $host "$cmd" > $logdir/$host.out 2> $logdir/$host.err &
done
wait

grep -l "No such file or" $logdir/* >> $logdir/missing_bd
sed -i '/Filesystem/d'    $logdir/*
sed -i '/gsvnx1fs3/d'     $logdir/*
grep -l "/$" $logdir/* >> $logdir/missing_bd

sed -i 's!'$logdir'/!!g' $logdir/missing_bd
sed -i 's/.err//g'       $logdir/missing_bd
sed -i 's/.out//g'       $logdir/missing_bd

if [ -s $logdir/missing_bd ]
then
  echo "the followng servers are missing /BD: $(cat $logdir/missing_bd)" | mailx -s "missing /BD" doronve@KUKU.com
fi

rm -rf  $logdir

let per=$(df -P /BD | awk '/Filesystem/{next}{print $5}' | sed 's/%//')
[[ ${per} -gt 98 ]] && mailx -s "/BD larger than 98%" doronve@KUKU.com avibn@KUKU.com

echo ""
