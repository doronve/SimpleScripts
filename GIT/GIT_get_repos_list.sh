#!/bin/bash
#
# Name: GIT_get_repos_list.sh
#
# Description: Compare two repos/branches
#
export BASEDIR=$(dirname $0)
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
export ALLFLAG="app"
while getopts :f:a: opt ; do
   case "$opt" in
      f) export REPFILE="$OPTARG" ;;
      a) export ALLFLAG="$OPTARG" ;;
      *) Usage ;;
   esac
done
[[ -z "${REPFILE}" ]] && Usage
}
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage()
{
  echo "Usage: $(basename $0) -f <Repos List File> [-a <all|app|10>]"
  echo ""
  echo "Where: <Repos List File> is the file to be generated."
  echo "       -a - whether to list all repos or just relevant ones"
  echo "Example: $(basename $0) -f /tmp/myrepofile.lst -a app"
  echo ""
  exit 1
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*

USER=USER
PASS=PASSWORD
NUM=1000


curl -u ${USER}:${PASS} \
     -k \
     -X GET \
     -H 'Content-Type: application/json' \
     -H 'Accept: application/json' \
     "https://GITSERVER/rest/api/1.0/projects/BDA/repos?limit=${NUM}" | jq .values[].slug | sed 's/"//g' > ${REPFILE}.tmp

sed -i '/engage/d' ${REPFILE}.tmp
[[ ${ALLFLAG} == "all" ]] && cp ${REPFILE}.tmp ${REPFILE}
[[ ${ALLFLAG} == "app" ]] && grep -x -v -f ${BASEDIR}/exclude_list.txt ${REPFILE}.tmp | grep -x -v -f ${BASEDIR}/aia-projects-black-list.txt | sort -u > ${REPFILE}
[[ ${ALLFLAG} == "10" ]]  && head -n 10 ${REPFILE}.tmp > ${REPFILE}


num_of_repos=`cat ${REPFILE} | wc -l`
echo "Number of repositories to dowload is : ${num_of_repos}"

rm -f ${REPFILE}.tmp
if [ ${num_of_repos} -eq 0 ] ; then
   echo "FAILED getting list of repositories!"
   exit 1
fi
