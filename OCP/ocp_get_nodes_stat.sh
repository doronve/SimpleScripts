#!/bin/bash 
export BASEDIR=$(dirname $0)
export PATH=/usr/local/bin:${PATH}

tempfile=$(mktemp)
echo OCP,Namespace,Size            > ${tempfile}.csv
bash /BD/Avi/OCP-Doron/Get_All.sh >> ${tempfile}.csv
bash ${BASEDIR}/../GEN/gen_csv_to_html.sh -i ${tempfile}.csv -o /var/www/html/ocp_all_nodes_size.html
