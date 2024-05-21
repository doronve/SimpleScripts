#!/bin/bash
export BASEDIR=$(dirname $0)

#
# Name: k8s_report_ns.sh
#
# Description: Generate a Report of a Namespace
#
export OCPSUPPORTED=ilocpdo408
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
export COMPONENTLIST=getAll
export OCP=ilocpdo408
while getopts :n:c:f:o: opt ; do
   case "$opt" in
      n) export NAMESPACE="$OPTARG" ;;
      f) export consoleTextName="$OPTARG" ;;
      o) export OCP="$(echo $OPTARG | awk -F\. '{print $1}')" ;;
      *) Usage ;;
   esac
done
[[ -z "${NAMESPACE}"       ]] && Usage
[[ -z "${OCP}"             ]] && Usage
[[ -z "${consoleTextName}" ]] && Usage
}
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage()
{
  echo "Usage:  $(basename $0) -n <NAMESPACE> -f <file> -o <OpenShift Cluster>"
  echo "Where: -n is the namespace"
  echo "       -f is the location of the consolText file"
  echo "       -o is the Openshift Cluster."
  echo "Example: $(basename $0) -n doronve-rt -f /path/to/consoleText -o OCP_HOST"
  echo ""
  exit 0
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*
export KUBECONFIG=$(mktemp /tmp/kubeconfig_XXX)
[[ ! -f ${BASEDIR}/../OCP/my_oc_login_${OCP}.sh ]] && echo "OOPSA: Cannot login to cluster ${OCP}. exiting." && exit 0
source ${BASEDIR}/../OCP/my_oc_login_${OCP}.sh ${BASEDIR}/../OCP/my_oc_login_${OCP}.sh 2> /dev/null > /dev/null

echo kubectl -n ${NAMESPACE} create configmap ${consoleTextName} --from-file=${consoleTextName}.gz
kubectl -n ${NAMESPACE} create configmap ${consoleTextName} --from-file=${consoleTextName}.gz

rm -f ${KUBECONFIG} 2> /dev/null > /dev/null
exit 0
