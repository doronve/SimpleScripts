#!/bin/bash
#
# Name: gen_get_os.sh
#
# Description: get cdh cluster full version
#

host=$1
[[ -z "$host" ]] && echo "NO_HOST" && exit 1

timeout 10 ssh -o ConnectTimeout=3 $host cat /etc/redhat-release | \
  sed 's/ (Ootpa)//' | \
  sed 's/ (Santiago)//' | \
  sed 's/ (Maipo)//' | \
  sed 's/Red Hat Enterprise Linux release /RHEL/' | \
  sed 's/Red Hat Enterprise Linux Server release /RHEL/'
