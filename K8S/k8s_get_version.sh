#!/bin/bash
#
# Name: k8s_get_version.sh
#
# Description: get k8s cluster version
#

host=$1
[[ -z "$host" ]] && echo NO_HOST && exit 1

timeout 10 ssh -o ConnectTimeout=3 $host kubectl version --short | sed 's/$/<\/br>/'
