#!/bin/bash

function Usage() {
  echo "Usage: $0 -u <URL of consoleText> [-f <output file>]"
  exit 1
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
export COMPLIST="all"
while getopts :u:f: opt ; do
   case "$opt" in
      u) export URL="$OPTARG" ;;
      f) export OUTFILE="$OPTARG" ;;
      *) Usage ;;
   esac
done
[[ -z "${URL}" ]]     && Usage
[[ -z "${OUTFILE}" ]] && OUTFILE=$(mktemp /tmp/consoleText_XXXX)
rm -f ${OUTFILE}
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*

unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
UUU=$(echo ${URL}| awk -F/ '{print $3}'|awk -F: '{print $1}')
export no_proxy="${UUU},${no_proxy}"

curl -s -S -u USER:PASSWORD "${URL}" -o ${OUTFILE} 2> /dev/null > /dev/null 

exit 0
