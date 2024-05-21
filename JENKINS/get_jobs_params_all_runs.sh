#!/bin/bash

export BASEDIR=$(dirname $0)
function Usage() {
  echo "Usage: $0 -j <Jon Name>"
  exit 1
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
export COMPLIST="all"
while getopts :j: opt ; do
   case "$opt" in
      j) export JOBNAME="$OPTARG" ;;
      *) Usage ;;
   esac
done
[[ -z "${JOBNAME}" ]]     && Usage
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*

export URL=https://JENKINSSERVER:18081/job/${JOBNAME}/rssAll

tmpdir=$(mktemp -d)
outfile=${tmpdir}/${JOBNAME}

bash $BASEDIR/get_consoleText.sh -u $URL -f ${outfile}_rssall

cat ${outfile}_rssall | tr '><' '>\n<' > ${outfile}_rssall.1
mv -f ${outfile}_rssall.1 ${outfile}_rssall

for href in $(awk -F\" '/href/{print $(NF-1)}' ${outfile}_rssall)
do
  num=$(echo $href | awk -F/ '{print $(NF-1)}')
  URL=https://JENKINSSERVER:18081/job/${JOBNAME}/${num}/parameters/
  bash $BASEDIR/get_consoleText.sh -u $URL -f ${outfile}.${num}
  cat ${outfile}.${num} | tr '><' '>\n<' > ${outfile}.${num}.1
  mv -f ${outfile}.${num}.1 ${outfile}.${num}
  awk -v num=${num} -F\" '/help-sibling/{aa=$NF}/value=/{printf("%s,%s,%s\n",num,aa,$(NF-1))}' ${outfile}.${num} >> ${outfile}.csv
done

ls -ld  ${outfile}*
#rm -f  $outfile
