#!/bin/bash
#
# Name: ocp_get_all_pvc.sh
#

export PATH=/usr/local/bin:${PATH}
export tmpfile=$(mktemp)
export myhomefile=/var/www/html/ocp_all_pvc.html
export BASEDIR=$(dirname $0)

function getData()
{
export KUBECONFIG=$(mktemp)
for oclogin in ${BASEDIR}/../OCP/my_oc*sh
do
  OCH=$(awk -F\. '/oc login/{print $2}' $oclogin)
  bash $oclogin > /dev/null 2> /dev/null
  for NS in $(oc get projects -o custom-columns=NAME:.metadata.name |grep -v -f ${BASEDIR}/../OCP/ocp_admin_projects.lst |grep -v NAME)
  do
    echo NS $NS
    oc -n $NS get pvc --no-headers=true 2> /dev/null
  done > ${tmpfile}_${OCH}
  awk -v OCH=${OCH} '/NS/{nn=$2;next}
       NF==4{printf("%s,%s,%s,%s,%s,%s,%s,%s,%s\n",OCH,nn,$1,$2,"","","",$3,$4);next}
       NF==7{printf("%s,%s,%s,%s,%s,%s,%s,%s,%s\n",OCH,nn,$1,$2,$3,$4,$5,$6,$7);next}
      ' ${tmpfile}_${OCH} > ${tmpfile}_${OCH}.csv
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

echo "created on $(date)" >> ${myhomefile}.new

echoHeaders Seq,OCP,Namespace,NAME,STATUS,VOLUME,CAPACITY,ACCESS MODES,STORAGECLASS,AGE

awk -F, '{
      printf("<tr><td>%d</td>",NR);
      printf("<td><a href=\"https://console-openshift-console.apps.%s.ocpd.corp.KUKU.com\" target=\"_blank\">%s</a></td>",$1,$1);
      printf("<td><a href=\"https://console-openshift-console.apps.%s.ocpd.corp.KUKU.com/k8s/ns/%s/persistentvolumeclaims\" target=\"_blank\">%s</a></td>",$1,$2,$2);
      printf("<td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n",$3,$4,$5,$6,$7,$8,$9);
     }' ${tmpfile}*csv >> ${myhomefile}.new

echo "
</tbody>
</table>
</html>
" >> ${myhomefile}.new
sed -i 's/Pending/<b><font color="red">Pending<\/font><\/b>/g' ${myhomefile}.new

mv ${myhomefile}         ${myhomefile}.$(date +%Y%m%d_%H%M%S)
mv -f ${myhomefile}.new  ${myhomefile}
#ls -ld ${tmpfile}*
rm -f ${tmpfile}*

grep -l Pending ${myhomefile} > /dev/null 2> /dev/null
if [ $? -eq 0 ]
then
  echo "There are Pending PVC. check http://$(hostname -i)/ocp_all_pvc.html ." | mailx -s "Pending PVC" doronve@KUKU.com
fi
