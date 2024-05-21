#!/bin/bash

for b in $(git branch -a|grep -v HEAD|grep -v master|grep -v ^\* | awk '{print $1}' )
do
  git reflog show --date=local $b
done
