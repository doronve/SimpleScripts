#!/bin/bash
#
# Name: ocp_get_all_exp_dates.sh
#

export Option=$1
export PATH=/usr/local/bin:${PATH}
export tmpfile=$(mktemp)
export myhomefile=/var/www/html/ocp_all_exp_dates.html
export MONITOR_DIR=/BD/Monitor

function getData()
{
export KUBECONFIG=$(mktemp)
for oclogin in ./OCP/my_oc_login*sh
do
  OCH=$(awk -F\. '/oc login/{print $2}' $oclogin)
  bash $oclogin > /dev/null 2> /dev/null
  for NS in $(oc get projects -o custom-columns=NAME:.metadata.name | grep -v -f OCP/ocp_admin_projects.lst | grep -v NAME)
  do
    oc get ns $NS -o yaml |\
      awk -v OCH=${OCH} '/display-name/{dn=$2;next}/creationTimestamp/{ct=$2;next}/ name:/{printf("%s,%s,%s,%s\n",OCH,$2,ct,dn)}' |\
      sed 's/"//g'
  done > ${tmpfile}_${OCH}.csv
  oc logout 2>&1 > /dev/null
done
rm -f $KUBECONFIG
}
function echoHeaders()
{
echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
'    >> ${myhomefile}.new 
echo $* | awk -F, '{for(i=1;i<=NF;i++){printf("<th>%s</th>",$i);}}END{printf("\n")}' >> ${myhomefile}.new 
echo '
</tr>
</thead>
<tbody>
'    >> ${myhomefile}.new 
}
#
# MAIN
#
getData
[[ "${Option}" == "1" ]] && cat ${tmpfile}*csv > ${MONITOR_DIR}/all_ocp_projects.csv && exit 0

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

echoHeaders Seq,OCP,Namespace,Creation Date,Expiration Date

awk -F, '{
      printf("<tr><td>%d</td>",NR);
      printf("<td><a href=\"https://console-openshift-console.apps.%s.ocpd.corp.KUKU.com\" target=\"_blank\">%s</a></td>",$1,$1);
      printf("<td><a href=\"https://console-openshift-console.apps.%s.ocpd.corp.KUKU.com/k8s/cluster/projects/%s/details\" target=\"_blank\">%s</a></td>",$1,$2,$2);
      printf("<td>%s</td><td>%s</td></tr>\n",$3,$4);
     }' ${tmpfile}*csv >> ${myhomefile}.new

echo "
</tbody>
</table>
</html>
" >> ${myhomefile}.new
sed -i 's/T..:..:..Z//g' ${myhomefile}.new

mv ${myhomefile}         ${myhomefile}.`date +%Y%m%d_%H%M%S`
mv -f ${myhomefile}.new  ${myhomefile}
#ls -ld ${tmpfile}*
cat ${tmpfile}*csv > ${MONITOR_DIR}/all_ocp_projects.csv
rm -f ${tmpfile}*

