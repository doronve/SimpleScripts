#!/bin/bash
#
# Name: ocp_get_all_pvc.sh
#

export PATH=/usr/local/bin:${PATH}
export tmpfile=$(mktemp /tmp/kfk_top_XXXX)
export myhomefile=/var/www/html/kafka_all_topics.html

function checkLsof()
{
mpid=""
for h in $(cat /BD/Monitor/CDH_Hosts_$(hostname).lst)
do
  nohup ssh $h lsof -i -P -n |grep LISTEN 2>&1 > ${tmpfile}.${h}.lsof &
  mpid="$mpid $!"
done
ps -fp $mpid
wait

ls -ld ${tmpfile}*
}
function checkTopics9092()
{
mpid=""
for file in $(grep -l 9092 ${tmpfile}.*.lsof)
do
  h=$(echo $file | awk -F\. '{print $3}')
  echo $h
  #nohup ssh $h kafka-topics --bootstrap-server ${h}:9092 --list 2>&1 > ${tmpfile}.$h &
  nohup /BD/SW/Kafka/kafka_2.13-2.8.0/bin/kafka-topics.sh --bootstrap-server ${h}:9092 --list > ${tmpfile}.${h}.topics 2> ${tmpfile}.${h}.err &
  mpid="$mpid $!"
done
ps -fp $mpid
wait
sed -i '/^Error/d' ${tmpfile}.*.topics
sed -i 's/__consumer_offsets/consumerOffsets/' ${tmpfile}.*.topics

#ls -lrtd ${tmpfile}*
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
checkLsof
checkTopics9092

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

echoHeaders Seq,Kafka,Prefix,Count

for file in ${tmpfile}.*.topics
do
  h=$(echo $file | sed 's/.topics$//' | sed "s!${tmpfile}.!!")
  awk -v h=$h -F_ '{cnt[$1]++}END{for(var in cnt){
  printf("%s,%s,%s\n",h,var,cnt[var]); }}' $file
done  >> ${tmpfile}.alltopics
awk -F, '{
      printf("<tr><td>%d</td>",NR);
      printf("<td><a href=\"http://%s:7180\" target=\"_blank\">%s</a></td>",$1,$1);
      printf("<td>%s</td><td>%s</td></tr>\n",$2,$3);
     }' ${tmpfile}.alltopics >> ${myhomefile}.new

echo "
</tbody>
</table>
</html>
" >> ${myhomefile}.new

mv ${myhomefile}         ${myhomefile}.`date +%Y%m%d_%H%M%S`
mv -f ${myhomefile}.new  ${myhomefile}
#ls -ld ${tmpfile}*
rm -f ${tmpfile}*

