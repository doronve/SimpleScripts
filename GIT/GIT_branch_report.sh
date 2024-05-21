#!/bin/bash
export BASEDIR=$(dirname $0)
#
# Name: GIT_branch_report.sh
#
# Description: Generate brance report of all GITSERVER repos
#
#------------------------------------------------------
# function getConsoleText
#------------------------------------------------------
function getConsoleText() {
  bash ${BASEDIR}/../JENKINS/get_consoleText.sh -u ${CONSOLETEXTURL} -f ${CONSOLETEXTFILE}
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
while getopts :f:u:o: opt ; do
   case "$opt" in
      f) export CONSOLETEXTFILE="$OPTARG" ;;
      u) export CONSOLETEXTURL="$OPTARG" ;;
      o) export OUTFILE="$OPTARG" ;;
      *) Usage ;;
   esac
done

[[ -z "${OUTFILE}" ]] && export OUTFILE=/var/www/html/GIT_branch_report.html
if [ -z "${CONSOLETEXTFILE}" ]
then
  export CONSOLETEXTFILE=$(mktemp /tmp/consoleText_XXX)
  export delfile=yes
  [[ ! -z "${CONSOLETEXTURL}"  ]] && getConsoleText && return
fi
  
}
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage()
{
  echo "Usage: $(basename $0) [-f <consoleText file> | -u <consoleText URL in Jenkins>] [-o <HTML output file>]"
  echo ""
  echo "Where: consoleText file is the log of the job already downloaded. default is 'consoleText'"
  echo "       consoleText URL is the URL for the log in Jenkins to be downloaded. no default"
  echo "       HTML output file - where the html will be written. default is '/var/www/html/GIT_branch_report.html'"
  echo "Note - provide either -f flag or -u flag. if provided both - will use the file"
  echo "Example1: $(basename $0) -f consoleText -o /var/www/html/git_repo_branches.html"
  echo "Example2: $(basename $0) -u http://JENKINSSERVER:18080/view/DevOps%20Tools/job/RunGitCommandOnAllRepos/47/consoleText -o /var/www/html/git_repo_branches.html"
  echo ""
  exit 1
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*
echo CONSOLETEXTFILE=${CONSOLETEXTFILE}
echo CONSOLETEXTURL =${CONSOLETEXTURL}
echo OUTFILE        =${OUTFILE}

commandToRun=$(awk -F= '/^commandToRun/{print $NF}' ${CONSOLETEXTFILE})
[[ "${commandToRun}" != " git branch -a" ]] && echo "job did not run with command 'git branch -a'. exiting." && exit 1

awk -F/ 'BEGIN{p=0;print "repo,count,branches"}
/HEAD/{next}
/^+/{next}
/^\*/{next}
/^.home/{repo=$NF;branches="";p=1;cnt=0;next}
/^status/{print repo "," cnt "," branches;next}
p==1{cnt++;branches=branches "</br>" $0;}
'  $CONSOLETEXTFILE > ${CONSOLETEXTFILE}.csv

sed -i 's/,<\/br>/,/g' ${CONSOLETEXTFILE}.csv
sed -i 's/ //g'        ${CONSOLETEXTFILE}.csv
bash ${BASEDIR}/../GEN/gen_csv_to_html.sh -i ${CONSOLETEXTFILE}.csv -o ${OUTFILE}
ls -ld -o ${OUTFILE}


#convert to python