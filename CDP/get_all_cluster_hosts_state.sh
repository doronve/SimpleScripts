#!/bin/bash
#
# Name: get_all_cluster_hosts_state
#
# Description: list all CDH and HDP nodes
#              list the state of all services
#
# Input: $1 - Env Type (ALL/NFT/Auto/Dev/Demo/etc.)
#        No input ==> Env Type=All
#
[[ -z "$EnvType" ]] && EnvType=ALL
MONITOR_DIR=/BD/Monitor

myhomefile=/var/www/html/myhome_${EnvType}.html
rm -f ${myhomefile}.mail
tmpmyhomefile=`mktemp /tmp/gachsXXXX --suffix .myhometmp`
newmyhomefile=`mktemp /tmp/gachsXXXX --suffix .myhomenew`

#---
echo '
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="refresh" content="1800">
        <title>BDA - List of Hadoop Clusters</title>
        <script type="text/javascript" src="myhome/JS/jquery-latest.js"></script>
        <script type="text/javascript" src="myhome/JS/__jquery.tablesorter.js"></script>
        <script type="text/javascript" src="myhome/JS/jquery.tablesorter.pager.js"></script>
        <script type="text/javascript" src="myhome/JS/chili-1.8b.js"></script>
        <script type="text/javascript" src="myhome/JS/docs.js"></script>

<script type="text/javascript" id="js">$(document).ready(function() {
        // call the tablesorter plugin
        $("table").tablesorter({
                // sort on the first column and third column, order asc
                sortList: [[0,0],[2,0]]
        });
}); </script>
</head>
' > ${newmyhomefile}

echo "created on `date`" >> ${newmyhomefile}

#<th>Yarn Stats</th>
#<th>Kafka Stats</th>
#<th>Hive Stats</th>
#<th>HBase Stats</th>
#<th>HDFS Stats</th>
echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
<th>Icon</th>
<th>Link</th>
<th>Version</th>
<th>Display Name</th>
<th>List of Nodes</th>
<th>Health</th>
<th>Various Stats</th>
<th>EnvType</th>
<th>Remark</th>
</tr>
</thead>
<tbody>
' >> ${newmyhomefile} 

sed -i 's/......KUKU.com//' ${MONITOR_DIR}/*lst
#---
# CDH
#---
cdh_hosts_file=${MONITOR_DIR}/CDH_Hosts_$(hostname).lst
sed -i '/192.168.2.100/d' $cdh_hosts_file
[[ "$EnvType" != "ALL" ]] && cdhhosts_lists=`grep -f ${MONITOR_DIR}/nodeslist_${EnvType}.lst ${cdh_hosts_file} | grep -v ^# | sort -u`
[[ "$EnvType" == "ALL" ]] && cdhhosts_lists=`cat ${cdh_hosts_file}  | grep -v ^# | grep -x -v -f /BD/Monitor/nodeslist_NFT.lst | sort -u`
#for cdhhost in `grep -v ^# ${cdh_hosts_file} |grep -v 192.168.2.100`
for cdhhost in $cdhhosts_lists
do
  nohup CDP/cdh_get_hosts.sh ${myhomefile} $cdhhost > /dev/null 2>/dev/null &
done
wait
[[ -f ${myhomefile}.new* ]] && cat ${myhomefile}.new* >> ${newmyhomefile}
rm -f ${myhomefile}.new*

#---
# HDP
#---
hdp_hosts_file=${MONITOR_DIR}/HDP_Hosts_$(hostname).lst
sed -i '/192.168.2.100/d' $hdp_hosts_file
[[ "$EnvType" != "ALL" ]] && hdphosts_lists=`grep -f ${MONITOR_DIR}/nodeslist_${EnvType}.lst ${hdp_hosts_file} | grep -v ^# | sort -u`
[[ "$EnvType" == "ALL" ]] && hdphosts_lists=`cat ${hdp_hosts_file}  | grep -v ^# | grep -v -f /BD/Monitor/nodeslist_NFT.lst | sort -u`
#for hdphost in `grep -v ^# ${hdp_hosts_file}`
for hdphost in $hdphosts_lists
do
  nohup CDP/hdp_get_hosts.sh ${myhomefile} $hdphost > /dev/null 2>/dev/null &
done
wait
[[ -f ${myhomefile}.new* ]] && cat ${myhomefile}.new* >> ${newmyhomefile}
rm -f ${myhomefile}.new*
#---
# MAPR
#---
mapr_hosts_file=${MONITOR_DIR}/MAPR_Hosts_$(hostname).lst
sed -i '/192.168.2.100/d' $mapr_hosts_file
[[ "$EnvType" != "ALL" ]] && maprhosts_lists=`grep -f ${MONITOR_DIR}/nodeslist_${EnvType}.lst ${mapr_hosts_file} | grep -v ^# | sort -u`
[[ "$EnvType" == "ALL" ]] && maprhosts_lists=`cat ${mapr_hosts_file}  | grep -v ^# | grep -v -f /BD/Monitor/nodeslist_NFT.lst | sort -u`
#for maprhost in `grep -v ^# ${mapr_hosts_file} |grep -v 192.168.2.100`
for maprhost in $maprhosts_lists
do
  nohup MAPR/mapr_get_hosts.sh ${myhomefile} $maprhost > /dev/null 2>/dev/null &
done
wait
[[ -f ${myhomefile}.new* ]] && cat ${myhomefile}.new* >> ${newmyhomefile}
rm -f ${myhomefile}.new*

#---
# CouchBase
#---
cb_hosts_file=${MONITOR_DIR}/CB_Hosts_$(hostname).lst
[[ "$EnvType" != "ALL" ]] && cbhosts_lists=`grep -f ${MONITOR_DIR}/nodeslist_${EnvType}.lst ${cb_hosts_file} | grep -v ^# | sort -u`
[[ "$EnvType" == "ALL" ]] && cbhosts_lists=`cat ${cb_hosts_file}  | grep -v ^# | grep -v -f /BD/Monitor/nodeslist_NFT.lst | sort -u`
for cbhost in $cbhosts_lists
do
  nohup CB/cb_get_hosts.sh ${myhomefile} $cbhost > /dev/null 2>/dev/null &
done
wait
[[ -f ${myhomefile}.new* ]] && cat ${myhomefile}.new* >> ${newmyhomefile}
rm -f ${myhomefile}.new*

#---
# Cassandra
#---
cas_hosts_file=${MONITOR_DIR}/CAS_Hosts_$(hostname).lst
[[ "$EnvType" != "ALL" ]] && cashosts_lists=`grep -f ${MONITOR_DIR}/nodeslist_${EnvType}.lst ${cas_hosts_file} | grep -v ^# | sort -u`
[[ "$EnvType" == "ALL" ]] && cashosts_lists=`cat ${cas_hosts_file}  | grep -v ^# | grep -v -f /BD/Monitor/nodeslist_NFT.lst | sort -u`
for cashost in $cashosts_lists
do
  nohup CAS/cas_get_hosts.sh ${myhomefile} $cashost > /dev/null 2>/dev/null &
done
wait
[[ -f ${myhomefile}.new* ]] && cat ${myhomefile}.new* >> ${newmyhomefile}
rm -f ${myhomefile}.new*

#---
# ElasticSearch
#---
es_hosts_file=${MONITOR_DIR}/ES_Hosts_$(hostname).lst
[[ "$EnvType" != "ALL" ]] && eshosts_lists=`grep -f ${MONITOR_DIR}/nodeslist_${EnvType}.lst ${es_hosts_file} | grep -v ^# | sort -u`
[[ "$EnvType" == "ALL" ]] && eshosts_lists=`cat ${es_hosts_file}  | grep -v ^# | grep -v -f /BD/Monitor/nodeslist_NFT.lst | sort -u`
for eshost in $eshosts_lists
do
  nohup ES/es_get_hosts.sh ${myhomefile} $eshost > /dev/null 2>/dev/null &
done
wait
[[ -f ${myhomefile}.new* ]] && cat ${myhomefile}.new* >> ${newmyhomefile}
rm -f ${myhomefile}.new*

#---
[[ -f ${myhomefile}.mail.* ]] && cat ${myhomefile}.mail.* >> ${myhomefile}.mail
rm -f ${myhomefile}.mail.*

if [ "${SENDMAIL}" == "yes" ]
then
  cntmail=`wc -l ${myhomefile}.mail | awk '{print $1}'`
  echo cntmail=$cntmail
  if [ $cntmail -gt 1 ]
  then
    cat ${myhomefile}.mail | mailx -s "some errors in clusters" doronve@KUKU.com
    cat ${myhomefile}.mail | mailx -s "some errors in clusters" Neelesh.Mehto@KUKU.com
  fi
fi

echo "
</tbody>
</table>
</html>
" >> ${newmyhomefile}

awk  '
/ GOOD /                           {print "<b><font color=\"green\">" ,$0,"</font></b>";next}
/ BAD /                            {print "<b><font color=\"red\">"   ,$0,"</font></b>";next}
/ CONCERNING /                     {print "<b><font color=\"orange\">",$0,"</font></b>";next}
/ DISABLED /                       {print "<b><font color=\"orange\">",$0,"</font></b>";next}
/ HISTORY_NOT_AVAILABLE /          {print "<b><font color=\"orange\">",$0,"</font></b>";next}
/ NOT_AVAILABLE /                  {print "<b><font color=\"red\">"   ,$0,"</font></b>";next}
/UNHEALTHY /             {if ($3>0){print "<b><font color=\"red\">"   ,$0,"</font></b>";next}}
/ALERT /                 {if ($3>0){print "<b><font color=\"red\">"   ,$0,"</font></b>";next}}
/HEARTBEAT_LOST /        {if ($3>0){print "<b><font color=\"red\">"   ,$0,"</font></b>";next}}
/UNKNOWN /               {if ($3>0){print "<b><font color=\"red\">"   ,$0,"</font></b>";next}}
/number of databases is/ {if ($5>10){print "<b><font color=\"red\">"  ,$0,"</font></b>";next}}
/Number-Of-Topic/      {if ($2>1000){print "<b><font color=\"red\">"  ,$0,"</font></b>";next}}
{print $0}
' ${newmyhomefile} > ${tmpmyhomefile} 
mv $myhomefile ${myhomefile}.`date +%Y%m%d_%H%M%S`
mv -f ${tmpmyhomefile}  $myhomefile
rm -f ${newmyhomefile}
chmod +r $myhomefile
