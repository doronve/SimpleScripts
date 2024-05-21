#!/bin/bash
#
# Name: k8s_report_ns.sh
#
# Description: Generate a Report of a Namespace
#
export BASEDIR=$(dirname $0)
export AVAILABLECOMPONENTS=getAll,getPodImages,getConfigMaps,getSecrets,getHelm
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
      c) export COMPONENTLIST="$OPTARG" ;;
      f) export REPFILE="$OPTARG" ;;
      o) export OCP="$(echo $OPTARG | awk -F\. '{print $1}')" ;;
      *) Usage ;;
   esac
done
[[ -z "${NAMESPACE}" ]] && Usage
[[ -z "${REPFILE}"   ]] && export REPFILE=$(mktemp /tmp/repfile_$(date +%s)_XXX.lst)
}
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage()
{
  echo "Usage:  $(basename $0) -n <NAMESPACE> [-c <Component1,component2,...>] [ -f <report file> ] [-o <OpenShift Cluster>]"
  echo "Where: -n is the namespace"
  echo "       -c is List of components to check, comma separated"
  echo "       -f is the location of the Repot file to be created"
  echo "       -o is the Openshift Cluster. Currently support only ${OCPSUPPORTED}"
  echo "       Components avaiable: ${AVAILABLECOMPONENTS}"
  echo "Example: $(basename $0) -n doronve-rt -c podImage -f /path/to/MyRep.txt"
  echo "Note: it is assumed that there is already access to the cluster"
  echo ""
  exit 0
}
function getAll() {
  getPodImages
  getConfigMaps
  getSecrets
  getHelm
}
function getPodImages() {
  echo getPodImages >> ${REPFILE}
  kubectl -n ${NAMESPACE} get pod -o custom-columns=CONTAINER:.spec.containers[0].name,IMAGE:.spec.containers[0].image | sort -u | sed 's/  */,/' |grep -v CONTAINER,IMAGE | sort -u >> ${REPFILE}
}
function getConfigMaps() {
  echo getConfigMaps >> ${REPFILE}
  kubectl -n ${NAMESPACE} get cm -o name | sort -u >> ${REPFILE}
}
function getSecrets() {
  echo getSecrets >> ${REPFILE}
  kubectl -n ${NAMESPACE} get secrets -o name | sort -u >> ${REPFILE}.sec
  # cleanup report
  sed -i "s/${NAMESPACE}/NAMESPACE/g"      ${REPFILE}.sec
  sed -i 's/dockercfg-.*$/dockercfg-XXX/g' ${REPFILE}.sec
  sed -i 's/token-.*$/token-XXX/g'         ${REPFILE}.sec
  cat ${REPFILE}.sec >> ${REPFILE} 
  rm -f ${REPFILE}.sec
}
function getHelm() {
  echo getHelm >> ${REPFILE}
  helm -n ${NAMESPACE} ls -a 2> /dev/null | awk '{print $1 "," $3 "," $9}' >> ${REPFILE}
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*
export KUBECONFIG=$(mktemp /tmp/kubeconfig_XXX)
[[ ! -f ${BASEDIR}/../OCP/my_oc_login_${OCP}.sh ]] && echo "cannot login to ${OCP}. exiting." && exit 0
source ${BASEDIR}/../OCP/my_oc_login_${OCP}.sh ${BASEDIR}/../OCP/my_oc_login_${OCP}.sh 2> /dev/null > /dev/null

rm -f ${REPFILE}
touch ${REPFILE}

for func in $(echo ${COMPONENTLIST} | sed 's/,/ /g')
do
  $func
done

cmname=$(echo ${REPFILE} | tr 'A-Z' 'a-z' | sed 's!/tmp/!!' | sed 's/_/-/g')
kubectl -n ${NAMESPACE} create configmap ${cmname} --from-file=${REPFILE}

rm -f ${KUBECONFIG} 2> /dev/null > /dev/null
exit 0
