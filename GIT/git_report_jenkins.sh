#!/bin/bash
#
# Name: git_report_jenkins.sh
#
# Description: Generate a report from a Jenkinsfile
#
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
while getopts :j: opt ; do
   case "$opt" in
      j) export JENKINSFILE="$OPTARG" ;;
      *) Usage ;;
   esac
done
[[ -z    "${JENKINSFILE}" ]] && Usage
[[ ! -f  "${JENKINSFILE}" ]] && Usage
}
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage()
{
  echo "Usage: $(basename $0) -j </path/to/jenkinsfile>"
  echo ""
  echo "Example: $(basename $0) -j ./Jenkisfile"
  echo ""
  exit 1
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*

#csvfile=$(mktemp -d /tmp/jenkins_XXX.csv)
tmpfile=$(mktemp /tmp/jenkinsfile_XXX)

cp ${JENKINSFILE}  $tmpfile

sed -i 's/{/{\'$'\n/g' ${tmpfile}
sed -i 's/{/\'$'\n{/g' ${tmpfile}
sed -i 's/}/}\'$'\n/g' ${tmpfile}
sed -i 's/}/\'$'\n}/g' ${tmpfile}
sed -i 's/,/ ,/g' ${tmpfile}
sed -i '/^$/d' ${tmpfile}

#echo "File,Lib,Agent,Stages"
awk -v ff=${JENKINSFILE} '
/library identifier/{LI=$3}
/label/{LB=$2}
/stage/{FS="[()]";ST=ST "|" $2}
END{printf("%s,%s,%s,%s\n",ff,LI,LB,ST)}
' ${tmpfile}

rm -f $tmpfile
