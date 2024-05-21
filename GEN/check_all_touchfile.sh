#!/bin/bash -x

touchfile=/var/www/html/touchfile.html
mv $touchfile ${touchfile}.`date +%Y%m%d_%H%M%S`
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
        <title>AIA - Check access to all VMs</title>
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
' > $touchfile

echo "created on `date`" >> $touchfile

echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
<th>Seq</th>
<th>Host</th>
<th>message</th>
</tr>
</thead>
<tbody>
' >> $touchfile


cmd="touch a"

logdir=/tmp/Logs_touch_`date +%Y%m%d_%H%M%S`
mkdir -p $logdir
for host in `bash GEN/get_hosts_list.sh `
do
  nohup timeout 10 ssh -o ConnectTimeout=3 ${remoteUser}@${host} "$cmd" > $logdir/$host.out 2> $logdir/$host.err &
done
wait

let i=1
for file in `ls -d $logdir/*out`
do
  host=`echo $file | awk -F/ '{gsub(/.out/,"");print $NF}'`
  echo "<tr><td>" $i "</td><td>" $host "</td><td>" `cat $logdir/${host}.*` "</td></tr>"
  let i=${i}+1
done >> $touchfile

#---

echo "
</tbody>
</table>
</html>
" >> $touchfile

cat $logdir/*err $logdir/*.out > $logdir/tomail.txt
sed -i '/Connection timed out during banner exchange/d' $logdir/tomail.txt

[[ -s $logdir/tomail.txt ]] && echo "http://$(hostname -i)/touchfile.html" | mailx -a $logdir/tomail.txt -s "some errors in hosts" doronve@KUKU.com

rm -rf $logdir
