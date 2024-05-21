#!/bin/bash

file=$1

for nip in `sort -u $file | grep -v [a-zA-Z]|grep -v ^#`
do
  #echo $nip
  hname=`timeout 10 ssh -o ConnectTimeout=3 $nip hostname`
  [[ $? -eq 0 ]] && sed -i 's/'$nip'$/'$hname'/' $file
done
