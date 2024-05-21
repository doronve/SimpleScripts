#!/bin/bash
exit 0
#
# Name: EH_check_consoleText.sh
#
# Input: Build URL
#
# Flow:
#   - download the consoleText into a file
#   - perform various checks on the log

function Usage() {
  echo "Usage: $0 -u <URL of consoleText>"
  exit 0
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
while getopts :u: opt ; do
   case "$opt" in
      u) export URL="$OPTARG" ;;
      *) Usage ;;
   esac
done
[[ -z "${URL}" ]]     && Usage
}

function getConsolText() {
  curl -s -S -u USER:PASSWORD "${URL}" -o ${OUTFILE} 2> /dev/null > /dev/null 
}
function printStartReportMsg() {
echo ""; echo ""; echo ""; echo ""; echo ""; echo ""; echo ""; echo ""; echo "";
echo "===================================="
echo "=                                  ="
echo "=   Analyze Console Text           ="
echo "=                                  ="
echo "===================================="
}
function printENDReportMsg() {
echo ""; echo ""
echo "===================================="
echo "=                                  ="
echo "=   END END END END END END        ="
echo "=                                  ="
echo "===================================="
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*

unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
UUU=$(echo ${URL}| awk -F/ '{print $3}'|awk -F: '{print $1}')
export no_proxy="${UUU},${no_proxy}"
export OUTFILE=$(mktemp)

getConsolText
printStartReportMsg

#Check Old Azure Proxy 10.67.4.6
grep -l 10.67.4.6 ${OUTFILE} > /dev/null 2> /dev/null
if [ $? -eq 0 ]
then
   echo "ConsoleText ERROR: proxy 10.67.4.6 was replaced with azureproxy.corp.KUKU.com!!"
   echo "ConsoleText ERROR: Please check your configuration file."
   echo "ConsoleText ERROR: Checking local files"
   echo "ConsoleText ERROR: grep -Rl 10.67.4.6 *"
   echo ""
   grep -Rl 10.67.4.6 *
fi

printENDReportMsg
