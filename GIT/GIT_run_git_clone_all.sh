#!/bin/bash
#------------------------------------------------------
# run_git_pull_all.sh
#------------------------------------------------------
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage() {
  echo "Usage: $0 -d <Git Extract Directory> -f <Repo List File> [-b <branch>]"
  echo "Where:"
  echo "   -d Direcoty where all git repos will be cloned"
  echo "   -f filename with list of all repos"
  echo "   -b branch name. default is master"
  echo "Example:"
  echo "   $0 -d GITDIR -f all_repos_files.lst -b v100.00"
  exit 1
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
  export BRANCHNAME="master"
  while getopts :d:f:b: opt; do
    case "$opt" in
    d) export GITDIR="$OPTARG" ;;
    f) export LISTFILE="$OPTARG" ;;
    b) export BRANCHNAME="$OPTARG" ;;
    *) Usage ;;
    esac
  done
  [[ -z "$GITDIR"   ]] && echo "Missing Directory." && Usage
  [[ -z "$LISTFILE" ]] && echo "Missing List File." && Usage
  [[ "${BRANCHNAME}" != "master" ]] && export BRANCHNAME="release/${BRANCHNAME}"
}
#
# MAIN
#

get_params $*

mkdir -p ${GITDIR}
cd ${GITDIR}

BATCH_SIZE=40
count=0

for repo in $(cat ${LISTFILE})
do
  nohup git clone --branch "${BRANCHNAME}" ssh://git@GITSERVER:7999/BDA/${repo}.git 2>&1 > ${repo}.log &
  ((count++))

  if [ ${count} -eq ${BATCH_SIZE} ]; then
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

echo "All repositories cloned."
