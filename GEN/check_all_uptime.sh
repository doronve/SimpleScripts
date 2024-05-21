#!/bin/bash
#
# Name: check_all_uptime.sh
#

uptimefile=/var/www/html/uptimefile.html
#mv $uptimefile ${uptimefile}.`date +%Y%m%d_%H%M%S`
WARN=100
CRIT=200
export BASEDIR=$(dirname $0)
remoteUser=$(bash ${BASEDIR}/../GEN/setRemoteUserName.sh)

tmpcsv=$(mktemp /tmp/uptime_XXX.csv)
#---

cmd="uptime"

logdir=/tmp/Logs_uptime_`date +%Y%m%d_%H%M%S`
mkdir -p $logdir
for host in `bash GEN/get_hosts_list.sh `
do
  nohup timeout 10 ssh -o ConnectTimeout=3 ${remoteUser}@${host} "$cmd" > $logdir/$host.out 2> $logdir/$host.err &
done
wait
echo "Host,time,up,user(s),load average 1,load average 2,load average 3" >> ${tmpcsv}

awk 'NF==13{print FILENAME "," $1 "," $3 "," $7 "," $11 $12 $13}' ${logdir}/*out >> ${tmpcsv}
awk 'NF==12{print FILENAME "," $1 "," $3 "," $6 "," $10 $11 $12}' ${logdir}/*out >> ${tmpcsv}
awk 'NF==11{print FILENAME "," $1 "1," $5 "," $9 $10 $11}'        ${logdir}/*out >> ${tmpcsv}
awk 'NF==10{print FILENAME "," $1 "1," $4 "," $8 $9 $10}'         ${logdir}/*out >> ${tmpcsv}

sed -i 's!/tmp/Logs_uptime_........_....../!!' ${tmpcsv}
sed -i 's/.out//' ${tmpcsv}

awk -F, -v warn=${WARN} -v crit=${CRIT} -v critfile=${tmpcsv}_crit.csv '$3<warn{ddd=$3;}
         $3>=warn{ddd="<b><font color=\"orange\">" $3 "</b>";}
         $3>=crit{ddd="<b><font color=\"red\">" $3 "</b>";print $0 > critfile}
         {printf("%s,%s,%s,%s,%s,%s,%s\n",$1,$2,ddd,$4,$5,$6,$7)}' ${tmpcsv} > ${tmpcsv}.new

nn=$(wc -l ${tmpcsv}_crit.csv | awk '{print $1}')
[[ ${nn} -gt 1 ]] && cat ${tmpcsv}_crit.csv | mailx -a ${tmpcsv}_crit.csv  -s "Host up Over 200 days" doronve@KUKU.com

#ls -ld ${tmpcsv}*
bash ${BASEDIR}/../GEN/gen_csv_to_html.sh -i ${tmpcsv}.new -o ${uptimefile}
#ls -ld ${logdir}  ${tmpcsv}*
rm -rf ${logdir}  ${tmpcsv}
