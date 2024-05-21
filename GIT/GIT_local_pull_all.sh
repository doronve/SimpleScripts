#!/bin/bash

export DIR=$1
[[ -z "${DIR}" ]] && export DIR=${PWD}

for d in ${DIR}/*
do
  cd $d
  pwd 
  nohup git pull > /dev/null 2> /dev/null &
done
ps -fe |grep git
wait
