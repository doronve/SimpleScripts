#!/bin/bash
#
# Name: check_all_nodes.sh
#
# Description: run check_single_node.sh and get info on the following:
# FQDN ,       Type,         OS,     MEM,     CPU,  last access, SW list/version: CDH, HDP, MapR, Docker, Cassandra, PostgreSQL, Oracle
# "${FQDN} # ${HOSTTYPE} # ${OS} # ${MEM} # ${mCPU} # ${LAST} # $CDHVER # $HDPVER # $MAPRVER # $DOCVER # $ESVER"

Type=$1
export BASEDIR=$(dirname $0)
remoteUser=$(bash ${BASEDIR}/../GEN/setRemoteUserName.sh)

if [ ! -z "$Type" ]
then
  nodesstat=/var/www/html/nodesstat_${Type}.html.tmp
  nodesstatorig=/var/www/html/nodesstat_${Type}.html
else
  nodesstat=/var/www/html/nodesstat.html.tmp
  nodesstatorig=/var/www/html/nodesstat.html
fi
#mv $nodesstat ${nodesstat}.$(date +%Y%m%d_%H%M%S)
WARN=90
CRIT=95

#---
echo '
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="refresh" content="1800">
        <title>DI - Detailed list of all nodes </title>
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
' > $nodesstat

echo "created on $(date)" >> $nodesstat

echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
<th>Seq</th>
<th>FQDN</th>
<th>Type</th>
<th>OS</th>
<th>MEM</th>
<th>CPU</th>
<th>uptime</th>
<th>LastAcess</th>
<th>CDH</th>
<th>Cassandra</th>
<th>PostgreSQL</th>
<th>Docker</th>
<th>K8S</th>
<th>ES</th>
<th>Jfrog</th>
<th>Oracle</th>
<th>JenkinsSlave</th>
<th>MySQL</th>
<th>Jenkins</th>
<th>Java</th>
<th>LSOF</th>
</tr>
</thead>
<tbody>
' >> $nodesstat


export cmd="bash /BD/DevOps/Generic_Tools/Monitor/check_single_node.sh"
export cmd1="bash /BD/DevOps/Generic_Tools/Monitor/get_node_data.sh"
[[ $(hostname) == "vm-ms360-automation" ]] && export cmd="bash GEN/check_single_node.sh"
[[ $(hostname) == "vm-ms360-automation" ]] && export cmd1="bash GEN/get_node_data.sh"

logdir=$(mktemp /tmp/dir_check_nodes_XXXX)
rm -rf $logdir
mkdir -p $logdir
for host in $(bash GEN/get_hosts_list.sh ${Type})
do
  [[ $(hostname) == "vm-ms360-automation" ]] && scp -r GEN ${remoteUser}@${host}:.
  nohup timeout 10 ssh -o ConnectTimeout=3 ${remoteUser}@${host} "$cmd" > $logdir/$host.out 2> $logdir/$host.err &
  nohup timeout 10 ssh -o ConnectTimeout=3 ${remoteUser}@${host} "$cmd1" > /dev/null  2> /dev/null &
done
wait

let i=1
for file in $logdir/*out
do
  awk -F# -v ii=$i ' { printf("<tr><td>%s</td>",ii); for(i=1;i<=NF;i++){printf("<td>%s</td>",$i);} printf("</tr>\n");} ' $file
  let i=${i}+1
done >> $nodesstat

#---

echo "
</tbody>
</table>
</html>
" >> $nodesstat

sed -i 's/Default string//'                              $nodesstat
sed -i 's/Virtual Platform//'                            $nodesstat
sed -i 's/VMware Virtual Platform/VMware/'               $nodesstat
sed -i 's/Red Hat Enterprise Linux release/RHEL/'        $nodesstat
sed -i 's/Red Hat Enterprise Linux Server release/RHEL/' $nodesstat
sed -i 's/5.15.0-1.cdh5.15.0.p0.21/cdh5.15.0/'           $nodesstat
sed -i 's/5.10.1-1.cdh5.10.1.p0.10/cdh5.10.1/'           $nodesstat
sed -i 's/5.14.4-1.cdh5.14.4.p0.3/cdh5.14.4/'            $nodesstat
sed -i 's/5.16.1-1.cdh5.16.1.p0.3/cdh5.16.1/'            $nodesstat
sed -i 's/5.8.2-1.cdh5.8.2.p0.3/cdh5.8.2/'               $nodesstat
sed -i 's/5.5.1-1.cdh5.5.1.p0.11/cdh5.5.1/'              $nodesstat
sed -i 's/SKU=NotProvided;ModelName=PowerEdge R720//'    $nodesstat
sed -i 's/767032-B21//'                                  $nodesstat
sed -i 's/603718-B21//'                                  $nodesstat
sed -i 's/507864-B21//'                                  $nodesstat
sed -i 's/7915LC5//'                                     $nodesstat
sed -i 's/7914AC1//'                                     $nodesstat
sed -i 's/7914Y6D//'                                     $nodesstat
sed -i 's/7915V1X//'                                     $nodesstat
sed -i 's/7914FT1//'                                     $nodesstat
sed -i 's/7915FT2//'                                     $nodesstat
sed -i 's/Maipo//'                                       $nodesstat
sed -i 's/Ootpa//'                                       $nodesstat
sed -i 's/IBM System/System/'                            $nodesstat
sed -i 's/M4 Server/M4/'                                 $nodesstat
sed -i 's/M4:/M4/'                                       $nodesstat
sed -i 's/Santiago//'                                    $nodesstat
sed -i 's/XxXxXxX//'                                     $nodesstat
sed -i 's/7945AC1//'                                     $nodesstat
sed -i 's/SKU=NotProvided;ModelName=PowerEdge R730xd//'  $nodesstat
sed -i 's/ (SKU=NotProvided;ModelName=PowerEdge R640)//' $nodesstat
sed -i 's/ : -\[]-//'                                    $nodesstat
sed -i 's/-\[]-//'                                       $nodesstat
sed -i 's/()//g'                                         $nodesstat
#sed -i 's/......KUKU.com//g'                           $nodesstat


rm -rf $logdir

mv $nodesstatorig ${nodesstatorig}.$(date +%Y%m%d_%H%M%S)
mv $nodesstat ${nodesstatorig}
nodesstatorig=/var/www/html/nodesstat.html
