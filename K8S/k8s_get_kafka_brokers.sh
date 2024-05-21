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
awk -v HH=$HH '/^NS/{aa=$2}/ kafka.brokers:/{print HH "," aa "," $2}' ${tmpfile} |sort -u | awk -F, '{print $1 "," $2 "," $3}' | sed 's/:909.//'

#ls -l $tmpfile
rm -f $tmpfile
