#!/bin/bash
export BASEDIR=$(dirname $0)

OUTFILE=$(mktemp)

echo "Cluster,Env,Kafka,Scylla,PostgreSQL,SnowFlake" >> $OUTFILE

ssh aia-oc-client-2 cat /home/i*[0-9]/all*csv >> ${OUTFILE}

nodesfile=/BD/Monitor/K8S_Hosts_$(hostname).lst
for host in $(cat $nodesfile | grep -v -f /BD/Monitor/nodeexeptions.lst)
do
  ssh aiamonitor@${host} cat all*csv >> ${OUTFILE}
done

sed -i '/,,,,/d' ${OUTFILE}

bash ${BASEDIR}/../GEN/gen_csv_to_html.sh -i $OUTFILE -o /var/www/html/all_envs.html
