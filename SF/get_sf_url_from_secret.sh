#!/bin/bash
#
# Name: get_sf_url_from_secret.sh
#
# Description: get Snowflake URL from secret of k8s
#
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
export SIMPLE="no"
while getopts :n: opt ; do
   case "$opt" in
      n) export NS="$OPTARG" ;;
      *) Usage ;;
   esac
done
[[ -z "${NS}" ]] && Usage
}
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage()
{
  echo "Usage:   $(basename $0) -n <NAMESPACE>"
  echo "Example: $(basename $0) -n nft-22-09-00-rt"
  echo ""
  exit 1
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*

tmpfile=${mktemp}
kubectl -n ${NS} get secret snowflake-db-secret -o yaml > $tmpfile
status=$?
awk '/snowflake_url_name/{print $2}' $tmpfile | base64 -d ; echo ""
rm -f $tmpfile
exit 0
