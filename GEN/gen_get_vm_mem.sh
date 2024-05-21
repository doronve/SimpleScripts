#!/bin/bash
#
# Name: gen_get_vm_mem.sh
#
# Description: get VM memory
#

host=$1
[[ -z "$host" ]] && echo "NO_HOST" && exit 1

timeout 10 ssh -o ConnectTimeout=3 $host free -g |  awk '/^Mem:/{print $2}'

