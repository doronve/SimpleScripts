#!/bin/bash
################################################################################
#
# Name: REPOS_check_readm.sh
#
################################################################################

export BASEDIR=$(dirname $0)

UUU=USER
PPP=PASSWORD
FLAGS="-k -X GET"
URL="https://GITSERVER/rest/api/1.0/projects/BDA/repos?limit=1000"

tmpfile=$(mktemp /tmp/all_repos_XXX.lst)
curl -u ${UUU}:${PPP} ${FLAGS} ${URL} | jq .values[].slug | sed 's/"//g' |grep -v -f ${BASEDIR}/repos_exceptions.lst | sort -u > $tmpfile

ls -ld $tmpfile

logfile=$(mktemp /tmp/REPOS_XXX.log)
tmpdir=$(mktemp -d /tmp/REPOS_XXX)
PPP=Brain%4012345678aia
split -l 10 $tmpfile ${tmpdir}/all_repos_

mkdir CLONES
cd CLONES

for file in ${tmpdir}/all_repos_*
do
  for repo in $(cat $file)
  do
    echo $repo
    nohup git clone https://${UUU}:${PPP}@GITSERVER/scm/bda/${repo}.git &
  done
  wait
done

for repo in ${PWD}/*
do
  cd $repo
  git status
  #bash ${BASEDIR}/REPOS_handle_readme.sh $repo 2>&1 | tee -a $logfile
done
rm -rf ${logfile} ${tmpdir}
