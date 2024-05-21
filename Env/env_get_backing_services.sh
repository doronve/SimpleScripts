#!/bin/bash
export BASEDIR=$(dirname $0)

HH=$1
[[ -z "${HH}" ]] && HH=$(hostname)
#tmpdir=$(mktemp -d)
#KUBECONFIG=${tmpdir}/config

tmpfile=$(mktemp)

for ns in $(kubectl get ns -o name|sed 's/namespace.//'|grep -v -f ${BASEDIR}/../OCP/ocp_admin_projects.lst)
do
  echo NS $ns >> ${tmpfile}
  kubectl -n $ns get cm -o yaml 2>&1 >> ${tmpfile}
  echo ===== >> ${tmpfile}
done
awk -v HH=$HH '/^NS/{printf("%s,%s,%s,%s,%s\n",HH,ns,kb[1],sy,pg[3]); ns=$2;kb[1]="";sy="";pg[3]=""}
               / kafka.brokers:/{nn=split($2,kb,",");}
               /aia.il.db.connstrings:/{sy=$2;}
               /postgres_url:/{nn=split($2,pg,":");}
' ${tmpfile} | sed 's/:909.//'
#awk '/ namespace:/{nn=$2}/aia.il.db.connstrings:/{print nn,$2}' ${tmpfile} |sort -u

#ls -l $tmpfile
rm -f $tmpfile
