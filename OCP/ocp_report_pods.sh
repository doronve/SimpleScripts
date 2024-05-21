#!/bin/bash
export PATH=/usr/local/bin:${PATH}
export BASEDIR=$(dirname $0)
#------------------------------------------------------
# ocp_report_pods.sh
#------------------------------------------------------
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage() {
  echo "Usage: $0 -c <Cluster Name> -n <Namespace>"
  echo "Examples:"
  echo "   $0 -c ilocpat402 -n myns-rt"
  echo "Cluster name must appear in login script under ${BASEDIR}/../OCP/my_login*sh"
  exit 0
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------

function get_params() {
  while getopts :c:n:o: opt; do
    case "$opt" in
    c) export CLUSTER_NAME="$(echo $OPTARG | awk -F\. '{print $1}')" ;;
    o) export CLUSTER_NAME="$(echo $OPTARG | awk -F\. '{print $1}')" ;;
    n) export NAMESPACE="$OPTARG" ;;
    *) Usage ;;
    esac
  done
  [[ -z "${CLUSTER_NAME}" ]] && echo "Missing Cluster Name" && Usage
  [[ -z "${NAMESPACE}" ]]    && echo "Missing Namespace"    && Usage
  [[ ! -f ${BASEDIR}/../OCP/my_oc_login_${CLUSTER_NAME}.sh ]] \
                             && echo "File ${BASEDIR}/../OCP/my_oc_login_${CLUSTER_NAME}.sh is missing. Cannot login to OCP." && Usage
}
#
# MAIN
#
get_params $*
tmpfile=$(mktemp)

BASENS=$(echo ${NAMESPACE} | sed 's/-au$//' | sed 's/-rt$//')
export KUBECONFIG=$(mktemp)
source ${BASEDIR}/../OCP/my_oc_login_${CLUSTER_NAME}.sh ${BASEDIR}/../OCP/my_oc_login_${CLUSTER_NAME}.sh 2> /dev/null > /dev/null
echo ""; echo ""; echo ""; echo ""; echo ""; echo ""; echo ""; echo ""; echo "";
echo "===================================="
echo "=                                  ="
echo "=   PODS ERRORS REPORT             ="
echo "=                                  ="
echo "===================================="
for ns in ${BASENS}-rt ${BASENS}-au
do
  echo "CLUSTER_NAME = ${CLUSTER_NAME}"
  echo "kubectl -n ${ns} get pods"
  kubectl -n ${ns} get pods
# Check pods that are in bad state
  kubectl -n ${ns} get pods | grep -f ${BASEDIR}/../OCP/pod_status_bad.lst > $tmpfile
# Check also pods that are running but failed (READY state is 0/1 or 0/2 etc/)
  kubectl -n ${ns} get pods | grep 0/ |grep Running >> $tmpfile
# Check also pods that have restart > 0
  kubectl -n ${ns} get pods | awk '$4>0' >> $tmpfile
  for pod in $(awk '{print $1}' ${tmpfile}|sort -u)
  do
    /BD/SW/Kubernetes/kubectl_v1.26.1 -n ${ns} events --for pod/${pod} 2>&1 |grep "LAST" > /dev/null 2> /dev/null
    if [ $? -eq 0 ]
    then
      echo "====== EVENTS FOR POD ${pod} ======="
      /BD/SW/Kubernetes/kubectl_v1.26.1 -n ${ns} get pod ${pod}
      /BD/SW/Kubernetes/kubectl_v1.26.1 -n ${ns} events --for pod/${pod} | grep -v Normal | tail -n 10
      echo "======-----------------------======="
      echo ""; echo ""
    fi
    kubectl -n ${ns} logs ${pod} > /dev/null 2> /dev/null
    if [ $? -eq 0 ]
    then
      echo "====== LOGS FOR POD ${pod} ======="
      /BD/SW/Kubernetes/kubectl_v1.26.1 -n ${ns} get pod ${pod}
      kubectl -n ${ns} logs ${pod} | grep -i -v INFO | tail -n 10
      echo "======-----------------------======="
      echo ""; echo ""
    fi
  done

done
echo ""; echo ""
echo "===================================="
echo "=                                  ="
echo "=   END END END END END END        ="
echo "=                                  ="
echo "===================================="

rm -f $KUBECONFIG $tmpfile 2> /dev/null > /dev/null
#ls -ld $KUBECONFIG $tmpfile
exit 0
