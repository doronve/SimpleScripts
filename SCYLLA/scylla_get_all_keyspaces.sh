#!/bin/bash
#
# Name: scylla_get_all_keyspaces.sh
#

export PATH=/usr/local/bin:${PATH}
export tmpfile=$(mktemp /tmp/scylla_XXXX)
export myhomefile=/var/www/html/scylla_all_keyspaces.html
export DIRNAME=$(dirname $0)

function checkAll()
{
  for host in $(sort -u /BD/Monitor/SCY_Hosts_*.lst | grep -v -f /BD/Monitor/nodeexeptions.lst)
  do
    sudo ssh ${host} rm -rf /tmp/SCYLLA_scripts
    sudo scp -r ${DIRNAME}/../SCYLLA ${host}:/tmp/SCYLLA_scripts
    sudo nohup ssh $host bash /tmp/SCYLLA_scripts/scylla_get_single_data.sh > ${tmpfile}.${host}.all 2> ${tmpfile}.${host}.err &
  done
  wait
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
checkAll

#---
echo '
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="refresh" content="1800">
        <title>AIA - List of Scylla Keyspaces</title>
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

echoHeaders Seq,Scylla Host,OS Version,Scylla Version,Keyspace,TLS,Encryption at REST,CPU,Memory

cat ${tmpfile}.*.all >> ${tmpfile}.allks

awk -F, '{
      printf("<tr><td>%d</td>",NR);
      printf("<td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n",$1,$2,$3,$4,$5,$6,$7,$8);
     }' ${tmpfile}.allks >> ${myhomefile}.new

echo "
</tbody>
</table>
</html>
" >> ${myhomefile}.new

sudo mv ${myhomefile}         ${myhomefile}.`date +%Y%m%d_%H%M%S`
sudo mv -f ${myhomefile}.new  ${myhomefile}
#ls -ld ${tmpfile}*
rm -f ${tmpfile}*

