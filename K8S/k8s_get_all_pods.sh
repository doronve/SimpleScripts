#!/bin/bash
#
# Name: k8s_get_all_pods.sh
#
# Description: get all pods from k8s cluster
#

host=$1
[[ -z "$host" ]] && echo "NO_HOST" && exit 1

timeout 10 ssh -o ConnectTimeout=3 $host kubectl get pods --all-namespaces | grep -v STATUS | grep -v ^kube-system | sed 's/ . */ - /g' | sed 's/$/<\/br>/'
