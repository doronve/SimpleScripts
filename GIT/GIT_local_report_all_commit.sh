#!/bin/bash

SINCE=2.days.ago
SINCE=2.weeks.ago
logfile=$(mktemp)
export DIR=$1
[[ -z "${DIR}" ]] && export DIR=${PWD}

for d in ${DIR}/*
do
  cd $d
  pwd 
  git log --pretty=format:"%ad##%ae##%d" --date=short --reverse --all --since=${SINCE}
done 2>&1 | tee ${logfile}

awk -F/ '/^\//{bb=$3;gg=$4;next}/^2/{print gg "##" bb "##" $0}' ${logfile} > ${logfile}.bla
ls -ld ${logfile}*
