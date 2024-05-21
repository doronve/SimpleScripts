#!/bin/bash

export BASEDIR=$(dirname $0)

tmpfile=$(mktemp)
tmpdir=$(mktemp -d)
for ocp in ${BASEDIR}/../OCP/my_oc_login*
do
  rm -f ${tmpfile}
  #echo ocp=$ocp
  OCH=$(awk -F\. '/oc/{print $2}' ${ocp})
  #echo OCH=$OCH
  export KUBECONFIG=${tmpdir}/config_${OCH}
  bash ${ocp} > /dev/null
  #bash ${ocp} 
  #nohup bash K8S/k8s_get_kafka_brokers.sh $OCH > ${tmpfile}_${OCH}.csv 2> ${tmpfile}_${OCH}.err &
  bash ${Xflag} K8S/k8s_get_kafka_brokers.sh   $OCH > ${tmpfile}_${OCH}.csv 2> ${tmpfile}_${OCH}.err
done
wait
#find ${tmpfile}* ${tmpdir}* -ls
cat ${tmpfile}_*.csv
