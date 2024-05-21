#!/bin/bash

export BASEDIR=$(dirname $0)
function Usage() {
  echo "Usage: $0 -u <URL of consoleText>"
  exit 1
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
export COMPLIST="all"
while getopts :u: opt ; do
   case "$opt" in
      u) export URL="$OPTARG" ;;
      *) Usage ;;
   esac
done
[[ -z "${URL}" ]]     && Usage
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*

outfile=$(mktemp /tmp/myfile_XXX.txt)

startedUser=na
bash $BASEDIR/get_consoleText.sh -u $URL -f $outfile

[[ -f $outfile ]] && startedUser=$(grep Started ${outfile} | sed 's/></>\n</g'|awk -F \" '/Started by user/{print $2}'|sed 's/.user.//g')
echo $startedUser

rm -f  $outfile
