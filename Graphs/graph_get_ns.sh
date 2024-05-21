#!/usr/bin/bash
export BASEDIR=$(dirname $0)
#------------------------------------------------------
# graph_get_ns.sh
#------------------------------------------------------
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage() {
  echo "Usage: $0 -c <Cluster Type> -n <cluster name>"
  echo "Examples:"
  echo "   $0 -c k8s -n aa-k8s-1"
  echo "   $0 -c ocp -n ilocpat402"
  echo "Cluster type can be k8s/ocp"
  exit 1
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------

function get_params() {
  while getopts :c:n: opt; do
    case "$opt" in
    c) CLUSTER_TYPE="$OPTARG" ;;
    n) CLUSTER_NAME="$OPTARG" ;;
    *) Usage ;;
    esac
  done
  [[ -z "$CLUSTER_TYPE" ]] && echo "Missing Cluster Type." && Usage
  [[ -z "$CLUSTER_NAME" ]] && echo "Missing Cluster Name" && Usage
  export k8shost=$CLUSTER_NAME
  [[ "$CLUSTER_TYPE" == "ocp" ]] && export k8shost=aia-oc-client-2
}
#
# MAIN
#
get_params $*

echo "in script $0"

color=blue
fontsize=24
fontsize=16
fontname="Palatino−Italic"
fontcolor=red
fontcolor=black
style=filled
style=solid

tmpfile=$(mktemp)
podlist=$(mktemp)
tmpfile=/tmp/GGG
echo "NAME
default
openshift
kube-node-lease
kube-public
kube-system
kubernetes-dashboard" > ${tmpfile}

if [ "$CLUSTER_TYPE" == "k8s" ]
then
NAMESPACES=$(ssh root@${k8shost} kubectl get ns | awk '{print $1}' | grep -v -f ${tmpfile})
else
NAMESPACES=$(bash ${BASEDIR}/../OCP/ocp_get_all_ns.sh $CLUSTER_NAME)
fi

GNAME=${k8shost}

echo "graph \"${GNAME}\" {"          > ${tmpfile}.gv
echo "subgraph \"cluster${GNAME}\"" >> ${tmpfile}.gv
echo "{"                            >> ${tmpfile}.gv
echo "layout=fdp"                   >> ${tmpfile}.gv
for ns in $NAMESPACES
do
  bash ${BASEDIR}/../OCP/ocp_get_all_pod_per_ns.sh $CLUSTER_NAME $ns > $podlist
  echo "subgraph \"cluster${ns}\" {
\"${ns}\" [label=\"${ns}\",color=${color},fontsize=${fontsize},fontname=${fontname},fontcolor=${fontcolor},style=${style}];
" >> ${tmpfile}.gv
  awk '{print "\"" $1 "\" [label=\"" $1,$2,$3 "\"\];"}' $podlist
echo "}" >> ${tmpfile}.gv
done
echo "}"  >> ${tmpfile}.gv
echo "}"  >> ${tmpfile}.gv

dot -Tsvg ${tmpfile}.gv -o ${tmpfile}.svg

ls -ld ${tmpfile}*
cp ${tmpfile}.svg /var/www/html/Graphs/.
ls -lrt /var/www/html/Graphs/*
