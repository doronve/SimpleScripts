#!/bin/bash
export BASEDIR=$(dirname $0)
#
# Name: git_compare_repos.sh
#
# Description: Compare two repos/branches
#
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
export COMPLIST="all"
while getopts :a:b:c: opt ; do
   case "$opt" in
      a) export REPOA="$OPTARG" ;;
      b) export REPOB="$OPTARG" ;;
      c) export COMPLIST="$OPTARG" ;;
      *) Usage ;;
   esac
done
[[ -z "${REPOA}" ]] && Usage
[[ -z "${REPOB}" ]] && Usage
}
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage()
{
  echo "Usage: $(basename $0) -a <repoA:branch> -b <repoB:branch> [-c <Components,List>]"
  echo ""
  echo "Where: RepoA/B are the repos to check, branch is the branch name."
  echo "       Components should be comma separated, and can be 'Jenkinsfile', 'pom.xml', 'dir-tree', 'readme' or 'all'"
  echo "       The script will compare the two repos and can be used to comare two branches of the same repo"
  echo "Example: $(basename $0) -a aia-il-sql-collector:v23.03.00 -b aia-parent-nonmsnext:v23.03.00 -c all"
  echo ""
  exit 1
}
function compareJenkins()
{
  bash ${BASEDIR}/git_report_jenkins.sh -j ${repo1}_${branch1}/Jenkinsfile
  bash ${BASEDIR}/git_report_jenkins.sh -j ${repo2}_${branch2}/Jenkinsfile
}
# --------------------- #
# - MAIN - #
# --------------------- #

get_params $*

tmpdir=$(mktemp -d /tmp/compare_XXX)

cd $tmpdir

repo1=$(echo ${REPOA}   | awk -F: '{print $1}')
branch1=$(echo ${REPOA} | awk -F: '{print $2}')
repo2=$(echo ${REPOB}   | awk -F: '{print $1}')
branch2=$(echo ${REPOB} | awk -F: '{print $2}')

git clone --branch ${branch1} ssh://git@GITSERVER:7999/bda/${repo1}.git
mv ${repo1} ${repo1}_${branch1}

git clone --branch ${branch2} ssh://git@GITSERVER:7999/bda/${repo2}.git
mv ${repo2} ${repo2}_${branch2}

pwd
ls -ld $PWD/*
