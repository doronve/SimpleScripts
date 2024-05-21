#!/bin/bash

NSLIST=$(kubectl get ns |grep -v -f namespace_blacklist.lst | awk '{print $1}' | sed 's/-au$//' | sed 's/-rt$//' | sort -u)

for ns in $NSLIST
do
  bash ocp_report_pods.sh -n ${ns} -c ilocpat402
done
