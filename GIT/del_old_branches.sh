#!/usr/bin/bash


DDATE=2022-1
csvfile=/tmp/tmp.vJSV4duqxM.csv
DIR=/home/jenkins/workspace/RunGitCommandOnAllRepos/ALLREPOS/master

sed -i '/master,/d' ${csvfile}
sed -i 's/refs.remotes.origin.//' ${csvfile}

awk -v DIR=$DIR -F, '/'${DDATE}'/{print "cd",DIR "/" $1,";git push origin --delete",$2}' ${csvfile} > del_${DDATE}.sh

ls -ld del_${DDATE}.sh

