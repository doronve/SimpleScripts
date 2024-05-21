#!/bin/bash
export PATH=/usr/local/bin:${PATH}
export BASEDIR=$(dirname $0)
export myhomefile=/var/www/html/ocp_all_events.html
#------------------------------------------------------
# Name: ocp_get_all_events.sh
#------------------------------------------------------
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage() {
  echo "Usage: $0 -c <Cluster Name> -f <output csv file>"
  echo "Examples:"
  echo "   $0 -c ilocpat402 -f /tmp/at40mynsrt_pods.csv"
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
    f) tmpfile="$OPTARG" ;;
    *) Usage ;;
    esac
  done
  [[ -z "${CLUSTER_NAME}" ]] && echo "Missing Cluster Name" && Usage
  [[ -z "${tmpfile}" ]]      && echo "Missing Output file"  && Usage
  export oclogin=${BASEDIR}/../OCP/my_oc_login_${CLUSTER_NAME}.sh
  [[ ! -f ${oclogin} ]] && echo "File ${oclogin} is missing. Cannot login to OCP." && Usage
}
#
# MAIN
#
get_params $*

export KUBECONFIG=$(mktemp)
bash $oclogin > /dev/null 2> /dev/null
for NS in $(oc get projects -o custom-columns=NAME:.metadata.name | grep -v -f  ${BASEDIR}/../OCP/ocp_admin_projects.lst | grep -v NAME)
do
  echo NS $NS
  oc -n $NS get events --no-headers=true 2> /dev/null
done > ${tmpfile}_${CLUSTER_NAME}
awk -v OCH=${CLUSTER_NAME} '/NS/{nn=$2;next}
       {printf("%s,%s,%s,%s,%s,%s,",OCH,nn,$1,$2,$3,$4);
       for(i=5;i<NF;i++){printf(" %s",$i)};printf("\n");
        next}
      ' ${tmpfile}_${CLUSTER_NAME} > ${tmpfile}_${CLUSTER_NAME}.csv
rm -f $KUBECONFIG

grep Normal ${tmpfile}_${CLUSTER_NAME}.csv > ${tmpfile}_${CLUSTER_NAME}.csv.Normal
sed -i '/Normal/d' ${tmpfile}_${CLUSTER_NAME}.csv

