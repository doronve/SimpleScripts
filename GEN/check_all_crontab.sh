#!/bin/bash
#
# Name: check_all_crontab.sh
#

crontabfile=/var/www/html/crontabfile.html
export BASEDIR=$(dirname $0)
tmpfile=$(mktemp /tmp/crontabs_XXX.tmp)

cmd="crontab -l"
cmd="grep -v ^# /var/spool/cron/*"

logdir=/tmp/Logs_crontab_`date +%Y%m%d_%H%M%S`
mkdir -p $logdir
for host in `bash ${BASEDIR}/../GEN/get_hosts_list.sh `
do
  nohup timeout 10 ssh -o ConnectTimeout=3 $host "$cmd" > $logdir/$host.out 2> $logdir/$host.err &
done
wait

for file in $logdir/*out
do
  sed -i '/^#/d' $file
  sed -i '/^$/d' $file
  sed -i '/:$/d' $file
  sed -i 's!/var/spool/cron/!!' $file
  sed -i 's/,/@@/g' $file
  grep -l : $file 2>&1 > /dev/null
  export uu="root,"
  if [ $? -eq 0 ]
  then
    export uu=""
    sed -i 's/:/,/' $file
  fi
  host=`echo $file | awk -F/ '{gsub(/.out/,"");print $NF}'`
  awk -v uu=${uu} -v host=${host} '{print host "," uu $0}' $file
done >> ${tmpfile}.csv
echo "Seq,Host,User,Command" > ${tmpfile}.csv1
awk '{print NR "," $0}' ${tmpfile}.csv >> ${tmpfile}.csv1

bash ${BASEDIR}/../GEN/gen_csv_to_html.sh -i ${tmpfile}.csv1 -o ${crontabfile}.tmp
sed -i 's/@@/,/g' ${crontabfile}.tmp
#---
#ls -ld $logdir/*
#ls -ld ${crontabfile}* ${tmpfile}*
rm -rf $logdir ${tmpfile}*
mv $crontabfile ${crontabfile}.`date +%Y%m%d_%H%M%S`
mv ${crontabfile}.tmp ${crontabfile}
