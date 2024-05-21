#!/bin/bash
export BASEDIR=$(dirname $0)
export MAILTO=kuku@KUKU.com

#check node status

export PATH="/usr/local/bin:${PATH}"
export logfile=$(mktemp /tmp/ocp_nodes_XXX.log)
export csvfile=$(mktemp /tmp/ocp_nodes_XXX.csv)
export tmpfile=$(mktemp /tmp/ocp_nodes_XXX.tmp)
export msgfile=$(mktemp /tmp/ocp_nodes_XXX.sh)
export KUBECONFIG=$(mktemp /tmp/ocp_nodes_XXX.kube.config)
echo "NAME,STATUS,ROLES,AGE,VERSION,INTERNAL-IP,EXTERNAL-IP,OS-IMAGE,KERNEL-VERSION,CONTAINER-RUNTIME" > ${csvfile}
touch  ${csvfile}.1
for oclogin in ${BASEDIR}/my_oc_login_*
do
  bash ${oclogin} 2>&1 | tee ${logfile}
  oc get nodes -o wide | awk '/^NAME/{next}{printf("%s,%s,%s,%s,%s,%s,%s,%s %s %s %s %s %s %s,%s,%s\n",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)}' >> ${csvfile}.1
  oc logout 2>&1 | tee ${logfile}
done

sort -u ${csvfile}.1 >> ${csvfile}

cntNotReady=$(grep -l NotReady ${csvfile} | wc -l)
touch ${tmpfile}
echo "</br>" >> ${tmpfile}
awk -F\. '/NotReady/{cnt[$2]++}
          END{for(var in cnt){
             isare="are";if(cnt[var]==1){isare="is"}
             printf("<font color='red'>There %3s %3s NotReady nodes in <b>%17s</b> cluster.</font></br>\n",isare,cnt[var],var)}}' ${csvfile} >> ${tmpfile}
echo "</br>" >> ${tmpfile}
echo '<a href="http://ilmtxbda73/ocp_all_nodes_state.html"   target="_blank">All OCP Nodes States</a></br>' >> ${tmpfile}
echo "</br>" >> ${tmpfile}
echo "Click twice on the 'STATUS' column and it will sort the table by this column. (works only in the URL not within the email" >> ${tmpfile}
echo "</br>" >> ${tmpfile}
echo "</br>" >> ${tmpfile}

sed -i 's/NotReady/<font color="red">NotReady<\/font>/g' ${csvfile}

bash ${BASEDIR}/../GEN/gen_csv_to_html.sh -i ${csvfile} -o /var/www/html/ocp_all_nodes_state.html -f ${tmpfile}

if [ $cntNotReady -gt 0 ]
then
  for sendto in $MAILTO
  do
    echo "mutt -e 'set content_type=text/html' -s 'There are OCP nodes with NotReady status' ${sendto} < /tmp/ocp_all_nodes_state.html" > ${msgfile}
  done
  scp /var/www/html/ocp_all_nodes_state.html aia-jenkins:/tmp/. > /dev/null 2> /dev/null
  scp ${msgfile}  aia-jenkins:${msgfile}   > /dev/null 2> /dev/null
  ssh aia-jenkins bash -x ${msgfile}
  ssh aia-jenkins rm -f ${msgfile} /tmp/ocp_all_nodes_state.html
fi

rm -f ${logfile}* ${csvfile}* ${tmpfile}* ${msgfile}* ${KUBECONFIG}*
