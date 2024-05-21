#!/bin/bash
#
# Name: k8s_get_nodes.sh
#
# Description: get all nodes from k8s cluster
#

host=$1
[[ -z "$host" ]] && echo "NO_HOST" && exit 1

timeout 10 ssh -o ConnectTimeout=3 $host kubectl get nodes | grep -v STATUS | sed 's/ . */ - /g' | sed 's/$/<\/br>/' | sed 's/<none>/none/g'
