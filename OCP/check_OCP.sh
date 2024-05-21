#!/bin/bash
BASEDIR=$(dirname $0)

#env|sort

#check login to Openshift Clusters

export PATH="/usr/local/bin:${PATH}"
logfile=/tmp/ocCheckLogin.lst
rm -f $logfile
let totalstat=0
tmpfile=/tmp/oc_nodes_`date +%Y%m%d_%H%M%S`.log
ocdesctmp=/tmp/oc_desc_nodes_`date +%Y%m%d_%H%M%S`.log
rm -f $tmpfile
#echo Name,Roles,OutOfDisk,MemoryPressure,DiskPressure,Ready,PIDPressure,cpu,memory,CPU Requests,CR%,CPU Limits,CL%,Memory Requests,MR%,Memory Limits,ML% > $tmpfile
for oclogin in ${BASEDIR}/my_oc_login_*
do
  echo ${oclogin}      | tee -a $logfile
  bash ${oclogin} 2>&1 | tee -a $logfile
  status=$?
  echo =============== | tee -a $logfile
  ocp=$(echo $oclogin | awk -F_ '{print $NF}' | sed 's/.sh//')
  echo status login to ${ocp} is $status | tee -a $logfile
  let totalstat=${totalstat}+${status}
  #oc projects
  oc describe nodes  >> $ocdesctmp
  oc logout > /dev/null 2> /dev/null
done
echo totalstat=$totalstat
[[ $totalstat -ne 0 ]] && cat $logfile | mailx -s "login error to one OCP cluster || ${BUILD_URL}" -a $logfile  doronve@KUKU.com
rm -f $logfile

awk '
/^Name/{printf("%s,%s,%s,%s,%s,%s,%s,%s,%s\n",nname,roles,OutOfDisk,MemoryPressure,DiskPressure,Ready,PIDPressure,ccpu,mmem);}
/^Name/{nname=$2;next}
/^Roles/{roles=$2;next}
/^  OutOfDisk/{OutOfDisk=$2;next}
/^  MemoryPressure/{MemoryPressure=$2;next}
/^  DiskPressure/{DiskPressure=$2;next}
/^  Ready/{Ready=$2;next}
/^  PIDPressure/{PIDPressure=$2;next}
/^Allocatable/{pp=1;next}
/^  cpu:/&&pp==1{ccpu=$2;next}
/^  memory:/&&pp==1{mmem=$2;next}
/^System Info/{pp=0;next}
'  $ocdesctmp >> $tmpfile

#awk '
#/^Name:/{printf("%s,",$2);}
#/^Roles:/{printf("%s,",$2);}
#/^  OutOfDisk/{OutOfDisk=$2}
#/^  MemoryPressure/{MemoryPressure=$2}
#/^  DiskPressure/{DiskPressure=$2}
#/^  Ready/{Ready=$2}
#/^  PIDPressure/{PIDPressure=$2}
#/^Addresses:/{printf("%s,%s,%s,%s,%s,",OutOfDisk,MemoryPressure,DiskPressure,Ready,PIDPressure);}
#/^Allocatable/{pp=1}
#/^ cpu:/&&pp==1{printf("%s,",$2);}
#/^ memory:/&&pp==1{printf("%s",$2);}
#/^System Info/{pp=0}
#/^  CPU Requests  CPU Limits/{getline;getline;for(i=1;i<=NF;i+=2){printf(",%s,%s",$i,$(i+1));}print ""}
#'  $ocdesctmp >> $tmpfile

awk '
/^Name:/{NN=$2;next;}
/^Roles:/{RR=$2;next;}
/^  Namespace/{getline;pp=1;next}
/^Allocated resources/{pp=0;next}
pp==1{printf("%s,%s",NN,RR);for(i=1;i<=NF;i++){printf(",%s",$i);}print ""}
'  $ocdesctmp >> ${tmpfile}_NS

sed -i 's/(//g' $tmpfile ${tmpfile}_NS
sed -i 's/)//g' $tmpfile ${tmpfile}_NS
sed -i 's/%//g' $tmpfile ${tmpfile}_NS

OCPstat=/var/www/html/OCPstat.html.tmp
OCPstatorig=/var/www/html/OCPstat.html
NSOCPstat=/var/www/html/NSOCPstat.html.tmp
NSOCPstatorig=/var/www/html/NSOCPstat.html
WARN=90
CRIT=95

#---
echo '
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="refresh" content="1800">
        <title>DI - Detailed list of all OCP nodes </title>
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
' > $NSOCPstat
echo "created on `date`" >> $NSOCPstat
echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
<th>Host</th>
<th>Roles</th>
<th>Namespace</th>
<th>Name</th>
<th>CPU Requests</th>
<th>CR%</th>
<th>CPU Limits</th>
<th>CL%</th>
<th>Memory Requests</th>
<th>MR%</th>
<th>Memory Limits</th>
<th>ML%</th>
</tr>
</thead>
<tbody>
' >> $NSOCPstat
awk -F, '
{printf("<tr>");
for(i=1;i<=NF;i++){
  AA="";BB=""
  if((i==6   && $i > 100) ||
     (i==8   && $i > 100) ||
     (i==10  && $i > 100) ||
     (i==12  && $i > 100)) {
    AA="<b><font color=\"red\">";BB="</font></b>";
  }
  printf("<td>%s%s%s</td>",AA,$i,BB);
  }
  printf("</tr>\n");}
' ${tmpfile}_NS >> $NSOCPstat

echo "
</tbody>
</table>
</html>
" >> $NSOCPstat

mv $NSOCPstatorig ${NSOCPstatorig}.`date +%Y%m%d_%H%M%S`
mv $NSOCPstat ${NSOCPstatorig}
NSOCPstatorig=/var/www/html/NSOCPstat.html

#---
echo '
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="refresh" content="1800">
        <title>DI - Detailed list of all OCP nodes </title>
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
' > $OCPstat

echo "created on `date`" >> $OCPstat

echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
<th>Name</th>
<th>Roles</th>
<th>OutOfDisk</th>
<th>MemoryPressure</th>
<th>DiskPressure</th>
<th>Ready</th>
<th>PIDPressure</th>
<th>cpu</th>
<th>memory</th>
<th>CPU Requests</th>
<th>CR%</th>
<th>CPU Limits</th>
<th>CL%</th>
<th>Memory Requests</th>
<th>MR%</th>
<th>Memory Limits</th>
<th>ML%</th>
</tr>
</thead>
<tbody>
' >> $OCPstat

awk -F, '
{printf("<tr>");
for(i=1;i<=NF;i++){
  AA="";BB=""
  if((i==3  && $i == "True" ) ||
     (i==4  && $i == "True" ) ||
     (i==5  && $i == "True" ) ||
     (i==6  && $i == "False") ||
     (i==7  && $i == "True" ) ||
     (i==13 && $i >  100   )) {
    AA="<b><font color=\"red\">";BB="</font></b>";
  }
  printf("<td>%s%s%s</td>",AA,$i,BB);
  }
  printf("</tr>\n");}
' $tmpfile >> $OCPstat
#awk -F, ' {printf("<tr>");for(i=1;i<=NF;i++){printf("<td>%s</td>",$i);} printf("</tr>\n");} ' $tmpfile >> $OCPstat

#---

echo "
</tbody>
</table>
</html>
" >> $OCPstat

mv $OCPstatorig ${OCPstatorig}.`date +%Y%m%d_%H%M%S`
mv $OCPstat ${OCPstatorig}
OCPstatorig=/var/www/html/OCPstat.html
