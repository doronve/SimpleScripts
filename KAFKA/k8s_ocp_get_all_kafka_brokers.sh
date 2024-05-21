#!/bin/bash
#
# Name: k8s_ocp_get_all_kafka_brokers.sh
#
export BASEDIR=`dirname $0`
export myhomefile=/var/www/html/k8s_ocp_kafka.html
export PATH=/usr/local/bin:${PATH}

tttmpfile=$(mktemp /tmp/kafka_XXXXX)

bash ${Xflag} ${BASEDIR}/KAFKA/k8s_get_all_kafka_brokers.sh >> ${tttmpfile}_k8s.csv
timeout 10 ssh aia-oc-client-2 bash ${Xflag} ${BASEDIR}/KAFKA/ocp_get_all_kafka_brokers.sh >> ${tttmpfile}_ocp.csv

#---
echo '
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="refresh" content="1800">
        <title>AIA - List of K8S Clusters</title>
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

echo "created on `date` </br>" >> ${myhomefile}.new
echo 'You can see most tokens for dashboards <a href="https://confluence/display/ATA/Dashboard+Tokens+for+most+k8s+clusters" target="_blank">HERE</a></br>' >> ${myhomefile}.new
echo "</br>" >> ${myhomefile}.new
echo "You can see full list of all OCP projects <a href="http://$(hostname)/ocp_projects.html" target="_blank">HERE</a></br>" >> ${myhomefile}.new
echo "</br>" >> ${myhomefile}.new
echo 'You can see full list of all K8S Clusters <a href="http://$(hostname).corp.KUKU.com/myhome_k8s_short.html" target="_blank">HERE</a></br>' >> ${myhomefile}.new
echo "</br>" >> ${myhomefile}.new

echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
<th>Num</th>
<th>Host</th>
<th>Namespaces</th>
<th>Kafka</th>
</tr>
</thead>
<tbody>
' >> ${myhomefile}.new 

awk -F, '{
  printf("<tr><td>%s</td>",NR);
  printf("<td><a href=\"https://%s:30000\" target=\"_blank\">%s</a></td>",$1,$1);
  printf("<td><a href=\"https://%s:30000/#/overview?namespace=%s\" target=\"_blank\">%s</td>",$1,$2,$2);
  printf("<td><a href=\"http://%s:7180\" target=\"_blank\">%s</a></td>",$3,$3);
  printf("</tr>\n");
}' ${tttmpfile}_k8s.csv >> ${myhomefile}.new

NN=$(wc -l ${tttmpfile}_k8s.csv|awk '{print $1}')

awk -F, -v NN=$NN '{
  printf("<tr><td>%s</td>",NR+NN);
  printf("<td><a href=\"https://console-openshift-console.apps.%s.ocpd.corp.KUKU.com\" target=\"_blank\">%s</a></td>",$1,$1);
  printf("<td><a href=\"https://console-openshift-console.apps.%s.ocpd.corp.KUKU.com/k8s/cluster/projects/%s\" target=\"_blank\">%s</a></td>",$1,$2,$2);
  printf("<td><a href=\"http://%s:7180\" target=\"_blank\">%s</a></td>",$3,$3);
  printf("</tr>\n");
}' ${tttmpfile}_ocp.csv >> ${myhomefile}.new


echo "
</tbody>
</table>
</html>
" >> ${myhomefile}.new
mv $myhomefile ${myhomefile}.`date +%Y%m%d_%H%M%S`
mv -f ${myhomefile}.new $myhomefile

rm -f ${tttmpfile}*
