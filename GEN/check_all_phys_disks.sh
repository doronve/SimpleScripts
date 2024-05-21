#!/bin/bash
################################################################################
#
# Name: check_all_phys_disks.sh
#
# Description: Check all physical disks
#
# Flow: - Prepare header
#       - Run check disks script on all physical machines
#
################################################################################

export BASEDIR=$(dirname $0)
remoteUser=$(bash ${BASEDIR}/../GEN/setRemoteUserName.sh)
diskfile=/var/www/html/diskfile.html
mv $diskfile ${diskfile}.$(date +%Y%m%d_%H%M%S)
WARN=90
CRIT=95

#---
echo '
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="refresh" content="1800">
        <title>BDA - List of all Physical Disks</title>
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
' > $diskfile

echo "created on $(date)" >> $diskfile

echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
<th>Seq</th>
<th>Host</th>
<th>Disk Number</th>
<th>Status</th>
</tr>
</thead>
<tbody>
' >> $diskfile


cmd="GEN/check_disks.sh"

logdir=/tmp/Logs_phys_$(date +%Y%m%d_%H%M%S)
mkdir -p $logdir

for host in $(sort -u nodeslist_phys.lst |grep -v ^# )
do
  nohup timeout 10 ssh -o ConnectTimeout=3 ${remoteUser}@${host} "$cmd" > $logdir/$host.out 2> $logdir/$host.err &
done
wait

let i=1
for file in $logdir/*out
do
  host=$(echo $file | awk -F/ '{gsub(/.out/,"");print $NF}')
  #echo host=$host
  awk -v host=$host -v i=$i '{gsub("Disk number","");sub(",","");mm=$4 " " $5 " " $6;
printf("<tr><td>%d</td><td>%s</td><td>%s</td><td>%s</td></tr>\n",i,host,$1,mm);i=i+1;
}' $file
let i=$i+$(wc -l $file|awk '{print $1}')
done | \
  sed 's/Unconfigured(good), Spun Up/<font color="orange">Unconfigured(good), Spun Up<\/font>/' | \
  sed 's/Unconfigured(bad)/<font color="red">ERROR - Unconfigured(bad)<\/font>/' | \
  sed 's/Failed/<font color="red">ERROR - Failed<\/font>/'  \
>> $diskfile

#---

echo "
</tbody>
</table>
</html>
" >> $diskfile

rm -rf $logdir

