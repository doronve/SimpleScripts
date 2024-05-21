#!/bin/bash
export BASEDIR=$(dirname $0)

function OCP() {
for u in OCPLIST
do
  ssh ${u}@aia-oc-client-2 bash ${BASEDIR}/../OCP/ocp_get_backing_services.sh
done
}

function K8S() {
nodesfile=/BD/Monitor/K8S_Hosts_$(hostname).lst
for host in $(cat $nodesfile | grep -v -f /BD/Monitor/nodeexeptions.lst)
do
  ssh root@${host}       bash ${BASEDIR}/../K8S/k8s_prep_aiamonitor.sh
  ssh aiamonitor@${host} bash ${BASEDIR}/../K8S/k8s_get_backing_services.sh
done
}

#OCP
K8S
