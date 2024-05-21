#!/bin/bash
#
# Name: get_env_type.sh
#
# Description: get environment type - according to existing or not in special list files
#
# input - $1 - host
#
host=$1

[[ -z "$host" ]] && echo "NO_HOST" && exit 1

EnvType=$(grep -l $host /BD/Monitor/nodeslist_*lst | sed 's/.BD.Monitor.nodeslist_//g' | sed 's/.lst//g')
[[ -z "$EnvType" ]] && EnvType="Generic"
echo $EnvType
