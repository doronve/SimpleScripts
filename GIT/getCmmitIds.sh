#!/bin/bash

function getCommitId() {

repoName=$1

cd ${BASEDIR}/${repoName}

for commitId in $(git log  --since="${start_date}" | grep ^commit | awk '{print $2}')
do
  author=$(git show ${commitId} | grep '^Author' | awk -F 'Author:' '{print $2}')
  commitDate=$(git show ${commitId} | grep '^Date:' | awk -F 'Date:' '{print $2}')
  commitURL="<a href=\"https://GITSERVER/projects/BDA/repos/${repoName}/commits/${commitId}\" target="_blank">${commitId}</a>"
  echo "${commitDate},${repoName},${author},${commitURL}" >> ${csvFileName}
done

}

# MAIN

projectList=$1
start_date=$2
BASEDIR=$3

#export BASEDIR=`readlink -f $(dirname $0)`

[[ -z $BASEDIR ]] && echo "`basename $0` <project_list.txt> 2024-05-02 /GIT-MASTER"  && exit 1

csvFileName="/tmp/repo_git_commit_ids_${start_date}.csv"

echo "Date,Repo Name,Author,Commit ID" > ${csvFileName}

for repo in `cat ${projectList} | grep -v '^#'`
do
    getCommitId ${repo}
done

/BD/GIT/aia-maintenance/GEN/gen_csv_to_html.sh -i ${csvFileName} -o ${csvFileName}.html

echo Report of dataone commits since ${start_date} | mailx -s "Report of dataone commits since ${start_date} ${BUILD_URL}" -a ${csvFileName}.html ${mailto} avibn@KUKU.com

ls -l ${csvFileName}
ls -l ${csvFileName}.html


mkdir -p ${WORKSPACE}/reports

cp -f ${csvFileName} ${csvFileName}.html ${WORKSPACE}/reports/.

rm -f ${csvFileName} ${csvFileName}.html


