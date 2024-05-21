#!/bin/bash
#
# Name: get_all_cluster_hosts_state_short.sh
#

myhomefile=/var/www/html/myhome_short.html
MONITOR_DIR=/BD/Monitor

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
' > ${myhomefile}.new

echo "created on `date`" >> ${myhomefile}.new

echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
<th>Num</th>
<th>Link</th>
<th>Version</th>
<th>Display Name</th>
<th>Secured</th>
<th>EnvType</th>
</tr>
</thead>
<tbody>
' >> ${myhomefile}.new 

let i=0
#---
cm_hosts_file=${MONITOR_DIR}/CDH_Hosts_$(hostname).lst
for cmhost in `grep -v ^# ${cm_hosts_file}`
do
  let i=${i}+1
  echo "<tr>" >> ${myhomefile}.new
  echo "<td>${i}</td>" >> ${myhomefile}.new
  echo "<td><a href=\"http://${cmhost}:7180\"  target=\"_blank\">${cmhost}</a></td>" >> ${myhomefile}.new
  echo "<td>`CDP/cdh_get_cluster_fullVersion.sh   $cmhost`</td>"              >> ${myhomefile}.new
  echo "<td>`CDP/cdh_get_cluster_displayName.sh   $cmhost`</td>"              >> ${myhomefile}.new
  echo "<td>`CDP/cdh_get_cluster_secured_state.sh $cmhost`</td>"              >> ${myhomefile}.new
  echo "<td>`CDP/cdh_get_cluster_secured_state.sh $cmhost`</td>"              >> ${myhomefile}.new
  echo "<td>`CDP/get_env_type.sh                  $cmhost`</td>"              >> ${myhomefile}.new
  echo "</tr>" >> ${myhomefile}.new
done

#---
hdp_hosts_file=${MONITOR_DIR}/HDP_Hosts_$(hostname).lst
for hdphost in `grep -v ^# ${hdp_hosts_file}`
do
  let i=${i}+1
  echo "<tr>" >> ${myhomefile}.new
  echo "<td>${i}</td>" >> ${myhomefile}.new
  echo "<td><a href=\"http://${hdphost}:8080\"  target=\"_blank\">${hdphost}</a></td>" >> ${myhomefile}.new
  echo "<td>`CDP/hdp_get_cluster_fullVersion.sh   $hdphost`</td>"               >> ${myhomefile}.new
  echo "<td>`CDP/hdp_get_cluster_displayName.sh   $hdphost`</td>"               >> ${myhomefile}.new
  echo "<td>`CDP/hdp_get_cluster_secured_state.sh $hdphost`</td>"               >> ${myhomefile}.new
  echo "<td>`CDP/get_env_type.sh                  $hdphost`</td>"               >> ${myhomefile}.new
  echo "</tr>" >> ${myhomefile}.new
done

#---
mapr_hosts_file=${MONITOR_DIR}/MAPR_Hosts_$(hostname).lst
for maprhost in `grep -v ^# ${mapr_hosts_file}`
do
  let i=${i}+1
  echo "<tr>" >> ${myhomefile}.new
  echo "<td>${i}</td>" >> ${myhomefile}.new
  echo "<td><a href=\"http://${maprhost}:8080\"  target=\"_blank\">${maprhost}</a></td>" >> ${myhomefile}.new
  echo "<td>`MAPR/mapr_get_cluster_fullVersion.sh   $maprhost`</td>"               >> ${myhomefile}.new
  echo "<td>`MAPR/mapr_get_cluster_displayName.sh   $maprhost`</td>"               >> ${myhomefile}.new
  echo "<td>`MAPR/mapr_get_cluster_secured_state.sh $maprhost`</td>"               >> ${myhomefile}.new
  echo "<td>`MAPR/get_env_type.sh                   $maprhost`</td>"               >> ${myhomefile}.new
  echo "</tr>" >> ${myhomefile}.new
done

echo "
</tbody>
</table>
</html>
" >> ${myhomefile}.new

mv $myhomefile ${myhomefile}.`date +%Y%m%d_%H%M%S`
mv -f ${myhomefile}.new $myhomefile
