#!/bin/bash
################################################################################
#
# Name: get_df_all_hosts.sh
#
# Descroption: get file system sizes of all servers in the list
#
################################################################################

export BASEDIR=$(dirname $0)
remoteUser=$(bash ${BASEDIR}/../GEN/setRemoteUserName.sh)
statfile=/var/www/html/statfile.html
mv $statfile ${statfile}.$(date +%Y%m%d_%H%M%S)
WARN=90
CRIT=95

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
' > $statfile 

echo "created on $(date)" >> $statfile

echo '
<table border="1" cellpadding="3"  id="myTable" class="tablesorter">
<thead>
<tr>
<th>Seq</th>
<th>Host</th>
<th>Filesystem</th>
<th>Size</th>
<th>Used</th>
<th>Available</th>
<th>Capacity</th>
<th>Mounted on</th>
</tr>
</thead>
<tbody>
' >> $statfile 

tmpdir=/tmp/get_df_all_$(date +%Y%m%d_%H%M%S)
mkdir $tmpdir
for lxhost in $(bash GEN/get_hosts_list.sh)
do
  nohup timeout 10 ssh -o ConnectTimeout=2 ${remoteUser}@${lxhost} df -hlP 2> $tmpdir/${lxhost}_df.err > $tmpdir/${lxhost}_df.out &
done
lxhost=AZURE-devops-centos-1
wait

sed -i '/mnt\//d'   $tmpdir/*_df.out
sed -i '/opswrk/d'  $tmpdir/*_df.out
sed -i '/overlay/d' $tmpdir/*_df.out
sed -i '/tmpfs/d'   $tmpdir/*_df.out

sendmailFlag=$(mktemp /tmp/get_df_all_hostsXXXXX)
rm -f $sendmailFlag
for file in $tmpdir/*_df.out
do
  h=$(echo $file|awk -F/ '{print $NF}' | sed 's/_df.out//')
  awk -v h=$h -v smf=$sendmailFlag '
   /^Filesystem/{next}
   {aa=$5;sub("%","",aa);
    bb=aa "%";
    if(aa>90){bb="<b><font color=\"orange\">" aa "%</b>";}
    if(aa>95){bb="<b><font color=\"red\">" aa "%</b>";print h,$0 >> smf ; }
    print h,$1,$2,$3,$4,bb,$6;}
' $file > ${file}.col
#diff -w ${file}.col ${file}
mv -f ${file}.col ${file}
done
  awk '
{ll="<tr><td>" NR "</td>" ;for(i=1;i<=NF;i++){ll=ll "<td>" $i "</td>";};print ll "</tr>";}
' $tmpdir/*_df.out >> $statfile

#---

echo "
</tbody>
</table>
</html>
" >> $statfile

sed 's/<.td><td>color/ color/' $statfile > ${statfile}.tmp
mv -f ${statfile}.tmp $statfile

sed -i -f GEN/get_df_all_hosts.sed $sendmailFlag

if [ -s $sendmailFlag ]
then
  echo "" >> $sendmailFlag
  echo http://$(hostname)/statfile.html >> $sendmailFlag
  for mailto in $(cat GEN/mailto.lst)
  do
    strings $sendmailFlag | mailx -s "check file system more than 95%" $mailto
  done
fi

rm -f $sendmailFlag
rm -rf $tmpdir
