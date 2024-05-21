#!/bin/bash

tmpfile=$(mktemp)
HH=$(hostname)

for ns in $(kubectl get ns -o name|sed 's/namespace.//')
do
  echo NS $ns >> ${tmpfile}
  kubectl -n $ns get cm -o yaml 2>&1 >> ${tmpfile}
  echo ===== >> ${tmpfile}
done
awk -v HH=$HH '/^NS/{aa=$2}/ kafka.brokers:/{print HH "," aa "," $2}' ${tmpfile} |sort -u


rm -f $tmpfile
