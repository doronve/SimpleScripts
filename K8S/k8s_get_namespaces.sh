#!/bin/bash
#
# Name: k8s_get_namespaces.sh
#
# Description: get all namespaces from k8s cluster
#
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
export SIMPLE="no"
while getopts :k:s opt ; do
   case "$opt" in
      k) export K8S_HOST="$OPTARG" ;;
      s) export SIMPLE="yes" ;;
      *) Usage ;;
   esac
done
[[ -z "${K8S_HOST}" ]] && Usage
}
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage()
{
  echo "Usage:   $(basename $0) -k <K8S_HOST> [-s]"
  echo "Where: -s is for a simple csv output"
  echo "Example: $(basename $0) -k xx-k8s-1"
  echo ""
  exit 1
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*

if [ "$SIMPLE" == "yes" ]
then
  timeout 10 ssh -o ConnectTimeout=3 ${K8S_HOST} kubectl get namespaces          | \
                  grep -v kube            | \
                  grep -v STATUS          | \
                  sed 's/ . */,/g'      | \
                  sed 's/^/'${K8S_HOST}',/g'
else
  timeout 10 ssh -o ConnectTimeout=3 ${K8S_HOST} kubectl get namespaces          | \
                  grep -v kube            | \
                  grep -v STATUS          | \
                  sed 's/ . */ - /g'      | \
                  sed 's/$/<\/br>/'
fi
