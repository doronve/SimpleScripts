#!/bin/bash
#
# Name: ocp_get_all_projects.sh
#
myhomefile=/var/www/html/ocp_projects.html
export PATH=/usr/local/bin:${PATH}
#---
echo '
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="refresh" content="1800">
        <title>AIA - List of OCP Projects</title>
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
<th>seq</th>
<th>ocp</th>
<th>Project</th>
<th>Owner</th>
<th>Created</th>
</tr>
</thead>
<tbody>
' >> ${myhomefile}.new 
#<th>Kafka</th>
#<th>Cassandra</th>

USER=USER
PASS=PASSWORD

HOSTLIST="OCPLIST"

tmpfile=`mktemp`
rm -f $tmpfile
let i=0
#---
#for ocphost in $HOSTLIST
for file in ./OCP/my_oc_login_*
do
  ocphost=$(echo $file | sed 's/..OCP.my_oc_login_//' | sed 's/.sh//')
  #oc login https://api.${ocphost}.ocpd.corp.KUKU.com:6443 --username ${USER} --password ${PASS} --insecure-skip-tls-verify=true
  bash $file
  oc get projects -o custom-columns=NAME:.metadata.name,OWNER:.metadata.annotations.openshift\\.io/requester,CREATED:.metadata.creationTimestamp > ${tmpfile}_${ocphost}_name
  oc status --all-namespaces > ${tmpfile}_${ocphost}_status
done
sed -i 's/T..:..:..Z//'      ${tmpfile}*_name
sed -i '/^NAME/d'            ${tmpfile}*_name
sed -i '/^open/d'            ${tmpfile}*_name
sed -i '/^debug/d'           ${tmpfile}*_name
sed -i '/^ocp4-collectl/d'   ${tmpfile}*_name
sed -i '/^kube/d'            ${tmpfile}*_name
sed -i '/^dedicated-admin/d' ${tmpfile}*_name
sed -i '/^default/d'         ${tmpfile}*_name
sed -i '/^chi-live-env/d'    ${tmpfile}*_name
sed -i '/^ci /d'             ${tmpfile}*_name
sed -i 's/<none>/none/g'     ${tmpfile}*_name
awk '{
      n=split(FILENAME,a,"_");
      m=n-1;
      hh="<a href=\"https://console-openshift-console.apps." a[m] ".ocpd.corp.KUKU.com/k8s/cluster/projects\"  target=\"_blank\">" a[m] "</a>";
      pp="<a href=\"https://console-openshift-console.apps." a[m] ".ocpd.corp.KUKU.com/k8s/ns/" $1 "/pods\"    target=\"_blank\">" $1   "</a>";
      kk="KAFKA_" a[m] "_" $1
      cc="CASSA_" a[m] "_" $1
      printf("<tr><td>%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td>",NR,hh,pp,$2,$3);
#      printf("<td>%s</td><td>%s</td></tr>\n",kk,cc);
     }' ${tmpfile}*_name >> ${myhomefile}.new
#awk '
#  /kafka/{
#      n=split(FILENAME,a,"_");
#      m=n-1;
#      p=split($0,b,"[");
#      q=split(b[p],c,"]");
#      printf("s@KAFKA_%s_%s@%s@\n",a[m],c[1],$NF);
#  }
#' ${tmpfile}_*_status > ${tmpfile}.sed
#awk '
#  /svc.cassandra/{
#      n=split(FILENAME,a,"_");
#      m=n-1;
#      p=split($0,b,"[");
#      q=split(b[p],c,"]");
#      printf("s@CASSA_%s_%s@%s@\n",a[m],c[1],$NF);
#  }
#' ${tmpfile}_*_status >> ${tmpfile}.sed
#sed -i -f ${tmpfile}.sed ${myhomefile}.new

echo "
</tbody>
</table>
</html>
" >> ${myhomefile}.new

mv ${myhomefile}         ${myhomefile}.`date +%Y%m%d_%H%M%S`
mv -f ${myhomefile}.new  ${myhomefile}
cp -f ${myhomefile}      ${myhomefile}_none
perl -p -e 's/></>\n</g' ${myhomefile} > ${myhomefile}.out
cp -f ${myhomefile}.out  ${myhomefile}
#sed -i '/none/d'         ${myhomefile}
#sed -i '/KAFKA/d'        ${myhomefile}
#sed -i '/CASS/d'         ${myhomefile}
