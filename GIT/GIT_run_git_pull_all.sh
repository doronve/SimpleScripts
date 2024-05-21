#!/bin/bash
#------------------------------------------------------
# run_git_pull_all.sh
#------------------------------------------------------
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage() {
  echo "Usage: $0 -d <Git Extract Directory>"
  echo "Where:"
  echo "   -d Direcoty where all git repos reside to be pulled"
  echo "Example:"
  echo "   $0 -d GITDIR -f all_repos_files.lst"
  exit 1
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
  while getopts :d: opt; do
    case "$opt" in
    d) export GITDIR="$OPTARG" ;;
    *) Usage ;;
    esac
  done
  [[ -z "$GITDIR"   ]] && echo "Missing Directory." && Usage
}
#
# MAIN
#

get_params $*

BATCH_SIZE=20
count=0

for repo in $(ls -d ${GITDIR}/*)
do
  cd ${repo}
  nohup git pull 2>&1 > ${repo}_pull_$(date +%s).log &
  ((count++))

  if [ $count -eq $BATCH_SIZE ]; then
    echo "Waiting for current batch to finish..."
    ps -fe |grep git
    wait
    count=0
  fi
done

# Wait for the remaining processes to finish
echo "Waiting for the last batch to finish..."
ps -fe |grep git
wait

echo "All repositories pulled"
