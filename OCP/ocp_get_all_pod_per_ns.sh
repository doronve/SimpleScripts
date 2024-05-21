#!/bin/bash
export PATH=/usr/local/bin:${PATH}
#------------------------------------------------------
# ocp_get_all_pod_per_ns.sh
#------------------------------------------------------
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage() {
  echo "Usage: $0 -c <Cluster Name> -n <Namespace> -f <output csv file>"
  echo "Examples:"
  echo "   $0 -c ilocpat402 -n myns-rt -f /tmp/at40mynsrt_pods.csv"
  echo "Cluster name must appear in login script under ./OCP/my_login*sh"
  exit 1
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------

function get_params() {
  while getopts :c:n:f: opt; do
    case "$opt" in
    c) CLUSTER_NAME="$OPTARG" ;;
    n) NAMESPACE="$OPTARG" ;;
    f) OUTFILE="$OPTARG" ;;
    *) Usage ;;
    esac
  done
  [[ -z "${CLUSTER_NAME}" ]] && echo "Missing Cluster Name" && Usage
  [[ -z "${NAMESPACE}" ]]    && echo "Missing Namespace"    && Usage
  [[ -z "${OUTFILE}" ]]      && echo "Missing Output file"  && Usage
  [[ ! -f ./OCP/my_oc_login_${CLUSTER_NAME}.sh ]] \
                             && echo "File ./OCP/my_oc_login_${CLUSTER_NAME}.sh is missing. Cannot login to OCP." && Usage
}
#
# MAIN
#
get_params $*
tmpfile=$(mktemp)

export KUBECONFIG=$(mktemp)
bash ./OCP/my_oc_login_${CLUSTER_NAME}.sh 2> /dev/null > /dev/null
kubectl -n ${NAMESPACE} get pods > $tmpfile
awk '{printf("%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$NF)}' $tmpfile > $OUTFILE

rm -f $KUBECONFIG $tmpfile
#ls -ld $KUBECONFIG $tmpfile
