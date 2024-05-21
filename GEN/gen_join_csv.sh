#!/bin/bash

file1=$1
file2=$2

HEADERFILE=$(mktemp)

awk -F, '{print $1}' ${file1} ${file2} | sort -u > ${HEADERFILE}

for head in $(cat ${HEADERFILE})
do
  H1=$(grep ${head}, ${file1} | sed "s/${head},//")
  H2=$(grep ${head}, ${file2} | sed "s/${head},//")
  echo ${head},${H1},${H2}
done
