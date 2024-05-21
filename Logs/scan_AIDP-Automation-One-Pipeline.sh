#!/bin/bash
export BASEDIR=$(dirname $0)
export MAILTO=doronve@KUKU.com
#
# Name: scan_AIDP-Automation-One-Pipeline.sh
#
# Description: Scan pipe line console output file for errors
# 
# Flow:
#  - download console text file
#  - scan for known errors
#  - for each error type run an action
#  - if console ends unseccuss and cannot find known error, send mail to devops
#
#--------------------------------------
# function Usage
#--------------------------------------
function Usage() {
  msg="$1"
  echo "$msg"
  echo "Usage: $0 -u Log URL [-t TYPE]"
  echo "Example: $0 -u https://JENKINSSERVER:18081/job/AIDP-Automation-One-Pipeline/3091/consoleText"
  echo " -t flag for future use - different types of pipelines maybe"
  exit 1
}
#--------------------------------------
# function get_parameters
#--------------------------------------
function get_parameters()
{
echo function get_parameters

while getopts t:u: opt
do
      case $opt in
         t) export TYPE=$OPTARG
            ;;
         u) export URL=$OPTARG
            ;;
         *) Usage
            ;;
      esac
done
echo TYPE  = $TYPE
echo URL   = $URL
[[ -z "${URL}" ]] && Usage "Missing URL"
}
get_parameters $*

#  - download console text file
LOGFILE=$(mktemp /tmp/consoleText_XXXX)
bash ${BASEDIR}/../JENKINS/get_consoleText.sh -u ${URL} -f ${LOGFILE}

#  - scan for known errors
CLUSTER_NAME=$(       awk '/CLUSTER_NAME:/{       print $NF;exit}' ${LOGFILE})
AUTHORING_NAMESPACE=$(awk '/AUTHORING_NAMESPACE:/{print $NF;exit}' ${LOGFILE})
RUNTIME_NAMESPACE=$(  awk '/RUNTIME_NAMESPACE:/{  print $NF;exit}' ${LOGFILE})
GEN_NS=$(echo ${AUTHORING_NAMESPACE} | sed 's/-au$//')
grep -f ${BASEDIR}/AIDP-Automation-One-Pipelin.err ${LOGFILE} |grep -v -f ${BASEDIR}/AIDP-Automation-One-Pipelin.skip > ${LOGFILE}.errors

#  - for each error type run an action

#  - if console ends unseccuss and cannot find known error, send mail to devops
[[ -z ${LOGFILE}.errors ]] && echo "${URL} has unknown (yet) errors" | mailx -s "new errors" $MAILTO}

ls -ld ${LOGFILE}*
