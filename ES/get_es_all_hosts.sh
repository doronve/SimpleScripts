#!/bin/bash -x
#
# Name: get_es_all_hosts.sh
#
echo no ES for you
exit 0

esfile=/var/www/html/esfile.html
mv $esfile ${esfile}.`date +%Y%m%d_%H%M%S`
WARN=90
CRIT=95
export BASEDIR=$(dirname $0)
remoteUser=$(bash ${BASEDIR}/../GEN/setRemoteUserName.sh)

#---
echo '
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="refresh" content="1800">
        <title>BDA - List of all Linux Servers</title>
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
' > $esfile 

echo "created on `date`" >> $esfile

echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
<th>Host</th>
<th>Filesystem</th>
<th>indices</th>
</tr>
</thead>
<tbody>
' >> $esfile 

tmpdir=/tmp/get_es_all_`date +%Y%m%d_%H%M%S`
mkdir $tmpdir
for lxhost in `bash GEN/get_hosts_list.sh`
do
  nohup timeout 10 ssh -o ConnectTimeout=2 ${remoteUser}@${lxhost} lsof -i -P -n 2> $tmpdir/${lxhost}_es.err > $tmpdir/${lxhost}_es.out &
done
wait

for host in `grep :9200 $tmpdir/*|grep LIST|awk -F: '{print $1}'|awk -F/ '{print $NF}'|sed 's/_es.out//'`
do
  echo "<tr>"
  echo "<td>"
  echo "<a href=\"http://$host:9200/_plugin/marvel/kibana/index.html\" target=\"_blank\">$host marvel</a></br>"
  echo "<a href=\"http://$host:9200/_plugin/gui/#/dashboard\" target=\"_blank\">$host gui</a></br>"
  echo "</td>"
  echo "<td><pre>"
  pp=`grep :9200 $tmpdir/${host}_es.out|grep LIST|awk '{print $2}'`
  files=`timeout 10 ssh -o ConnectTimeout=2 ${remoteUser}@${host} lsof -p $pp |grep REG|awk '{print $NF}'|grep node|awk -F/ '{print "/" $2}' |sort -u`
  timeout 10 ssh -o ConnectTimeout=2 ${remoteUser}@${host} df -hlP $files | sort -u |grep -v Filesystem 
  echo "</pre></td>"
  echo "<td>"
for ix in `/usr/bin/curator --host $host show indices --all-indices|grep -v INFO|grep -v marvel`
do
echo "$ix </br>"
done
  echo "</td>"
  echo "</tr>"
done >> $esfile


#---

echo "
</tbody>
</table>
</html>
" >> $esfile

sed 's/<.td><td>color/ color/' $esfile > ${esfile}.tmp
mv -f ${esfile}.tmp $esfile
rm -rf $tmpdir

exit
awk  '
/ GOOD /                 {print "<b><font color=\"green\">" ,$0,"</font></b>";next}
/ BAD /                  {print "<b><font color=\"red\">"   ,$0,"</font></b>";next}
/ CONCERNING /           {print "<b><font color=\"orange\">",$0,"</font></b>";next}
/ DISABLED /             {print "<b><font color=\"orange\">",$0,"</font></b>";next}
/ HISTORY_NOT_AVAILABLE /{print "<b><font color=\"orange\">",$0,"</font></b>";next}
/ NOT_AVAILABLE /        {print "<b><font color=\"orange\">",$0,"</font></b>";next}
/UNHEALTHY /   {if ($3>0){print "<b><font color=\"red\">"   ,$0,"</font></b>";next}}
{print $0}
' $esfile > ${esfile}.tmp
mv -f ${esfile}.tmp $esfile

