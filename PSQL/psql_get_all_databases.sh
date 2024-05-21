#!/bin/bash
export BASEDIR=$(dirname $0)
#
# Name: psql_get_all_databases.sh
#

export PATH=/usr/local/bin:${PATH}
export tmpfile=$(mktemp /tmp/psql_XXXX)
export myhomefile=/var/www/html/psql_all_databases.html

function checkAll()
{
  for host in $(sort -u /BD/Monitor/PSQL_Hosts_*.lst | grep -v -f /BD/Monitor/nodeexeptions.lst)
  do
    nohup ssh $host bash ${BASEDIR}/../PSQL/psql_get_single_data.sh > ${tmpfile}.${host}.all 2> ${tmpfile}.${host}.err &
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
        <title>AIA - List of PSQL Databases</title>
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

echoHeaders Seq,PSQL Host,OS Version,PSQL Version,database,CPU,Memory,CDH

cat ${tmpfile}.*.all >> ${tmpfile}.allks

awk -F, '{
      printf("<tr><td>%d</td>",NR);
      printf("<td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n",$1,$2,$3,$4,$5,$6,$7);
     }' ${tmpfile}.allks >> ${myhomefile}.new

echo "
</tbody>
</table>
</html>
" >> ${myhomefile}.new

mv ${myhomefile}         ${myhomefile}.`date +%Y%m%d_%H%M%S`
mv -f ${myhomefile}.new  ${myhomefile}
#ls -ld ${tmpfile}*
rm -f ${tmpfile}*

