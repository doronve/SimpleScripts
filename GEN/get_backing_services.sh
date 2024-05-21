#!/usr/bin/bash

export OPERATIONLIST=getKafka,getCassandra,getPSQL,getSshDocker,getRA,getAll
#------------------------------------------------------
# get_backing_services.sh
#------------------------------------------------------
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage() {
  echo "Usage: $0 -n namespaces [-o option] [-h]"
  echo ""
  echo "-n for a list of namespaces, comma separated"
  echo "-o for Operation list, comma seperated. available Operations: ${OPERATIONLIST}"
  echo "-h for help"
  echo "This script Extract the Backing services used in the given namespace(s)."
  echo "Example:"
  echo "   $0 -n ns1,ns2 -o getKafka"
  exit 1
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
  while getopts :n:o: opt; do
    case "$opt" in
    n) export NSLIST="$(echo ${OPTARG} | sed 's/,/ /g')" ;;
    o) export OPLIST="$(echo ${OPTARG} | sed 's/,/ /g')" ;;
    *) Usage ;;
    esac
  done
  [[ -z "${OPLIST}" ]] && export OPLIST="getAll"


}
function getKafka() {
  kubectl -n $ns get cm kafka-service-broker-configmap -o yaml 2> /dev/null | awk -v ns=${ns} -F: '
{gsub(" ","",$0);}
/authoring-cluster:/ {aa=$1}
/fnd_kafka_cluster:/ {aa=$1}
/kafka-c1:/ {aa=$1}
/kafka-d1:/ {aa=$1}
/kafka-nts:/ {aa=$1}
/kafka-r1:/ {aa=$1}
/productionrelease-cluster:/ {aa=$1}
/productionruntime-cluster:/ {aa=$1}
/testingrelease-cluster:/ {aa=$1}
/testingruntime-cluster:/ {aa=$1}
/kafkaurls:/ {n=split($2,a,",");print ns ",KAFKA," aa "," a[1]}
'
}
function getPSQL() {
  for sec in $(kubectl -n $ns get secrets | awk '/^postgres/{print $1}')
  do
    UU=$(kubectl -n $ns get secrets $sec -o yaml | awk '/url/{print $NF}')
    [[ ! -z "${UU}" ]] && echo "${ns},PSQL,$(echo $UU | base64 -d | awk -F/ '{print $3}')"
  done
  for cm in aia-common-repository-authoring-configmap aia-env-manager-configmap
  do
    UU=$(kubectl -n ${ns} get cm ${cm} -o yaml 2> /dev/null |awk -F/ '/postgres_url/{print $3}')
    [[ ! -z "${UU}" ]] && echo "${ns},PSQL,$UU"
  done
}
function getCassandra() {
  kubectl -n $ns get svc |awk -v ns=${ns} '/cas/{print ns ",CASSANDRA," $4}'
}
function getSshDocker() {
  kubectl -n ${ns} get deploy aia-jenkins -o yaml 2> /dev/null |grep -a1 DOCKER_SERVER_NAME$ | tail -n 1 | awk -v ns=${ns} '{print ns ",SSHREMOTE," $NF}'
}
function getRA() {
  RA=$(kubectl -n ${ns} get cm fndsec-pki-operator-configmap-config -o yaml 2> /dev/null |awk -F/ '/ra-url/{print $3}'| sed 's/\\n .*//g')
  [[ ! -z "${RA}" ]] && echo "${ns},RASERVER,$RA"
}
function getAll() {
  for OP in $(echo ${OPERATIONLIST} | sed 's/,/ /g' | sed 's/getAll//')
  do
    ${OP}
  done
}
#
# MAIN
#
get_params $*

for ns in ${NSLIST}
do
  for OP in ${OPLIST}
  do
    $OP
  done
done
