#!/bin/bash
export PATH=/usr/local/bin:${PATH}
export BASEDIR=$(dirname $0)
#------------------------------------------------------
# ocp_get_all_pod_per_ns.sh
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
  while getopts :c:f: opt; do
    case "$opt" in
    c) CLUSTER_NAME="$OPTARG" ;;
    f) OUTFILE="$OPTARG" ;;
    *) Usage ;;
    esac
  done
  [[ -z "${CLUSTER_NAME}" ]] && echo "Missing Cluster Name" && Usage
  [[ -z "${OUTFILE}" ]]      && echo "Missing Output file"  && Usage
  [[ ! -f ${BASEDIR}/../OCP/my_oc_login_${CLUSTER_NAME}.sh ]] \
                             && echo "File ${BASEDIR}/../OCP/my_oc_login_${CLUSTER_NAME}.sh is missing. Cannot login to OCP." && Usage
}
#
# MAIN
#
get_params $*
tmpfile=$(mktemp)

export PATH=/usr/local/bin:${PATH}
export KUBECONFIG=$(mktemp)
bash ${BASEDIR}/../OCP/my_oc_login_${CLUSTER_NAME}.sh 2> /dev/null > /dev/null
kubectl get pods --all-namespaces |grep -v Running | grep -v Completed |grep -v Termin> $tmpfile
status=$?
echo status=$status
sed -i '/^open/d' $tmpfile
sed -i '/^ocp/d' $tmpfile
sed -i '/^kube/d' $tmpfile
sed -i '/^chi-live-env/d' $tmpfile
awk '/ImagePullBackOff/{print "kubectl -n",$1,"describe pod",$2,"|awk -v nn=" $1,"-v pp=" $2,"vv/Back-off/{print nn,\",\",pp,\",\",$NF}'vv'"}' ${tmpfile} > ${tmpfile}_ImagePullBackOff.sh
awk '{printf("%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$NF)}' $tmpfile > $OUTFILE
bash ${BASEDIR}/../GEN/gen_csv_to_html.sh -i $OUTFILE -o /tmp/all_pods_${CLUSTER_NAME}.html
#sed -i 's/Running/<b><font color="green">Running<\/font><\/b>/'                 /tmp/all_pods_${CLUSTER_NAME}.html
#sed -i 's/Completed/<b><font color="green">Completed<\/font><\/b>/'             /tmp/all_pods_${CLUSTER_NAME}.html
#sed -i 's/CrashLoopBackOff/<b><font color="red">CrashLoopBackOff<\/font><\/b>/' /tmp/all_pods_${CLUSTER_NAME}.html
sed -i -f ${BASEDIR}/sed_status.sed /tmp/all_pods_${CLUSTER_NAME}.html
sed -i 's/0\/1/<b><font color="red">0\/1<\/font><\/b>/'                         /tmp/all_pods_${CLUSTER_NAME}.html
sed -i 's/0\/2/<b><font color="red">0\/2<\/font><\/b>/'                         /tmp/all_pods_${CLUSTER_NAME}.html
sed -i 's/1\/2/<b><font color="red">1\/2<\/font><\/b>/'                         /tmp/all_pods_${CLUSTER_NAME}.html
sudo mv /var/www/html/all_pods_${CLUSTER_NAME}.html /var/www/html/all_pods_${CLUSTER_NAME}.html_$(date +%Y%m%d_%H%M%S)
sudo cp -f /tmp/all_pods_${CLUSTER_NAME}.html /var/www/html/all_pods_${CLUSTER_NAME}.html

rm -f $KUBECONFIG $tmpfile
#ls -ld ${KUBECONFIG} ${tmpfile} ${OUTFILE}  /tmp/all_pods_${CLUSTER_NAME}.html
