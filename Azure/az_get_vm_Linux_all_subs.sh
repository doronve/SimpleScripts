#!/bin/bash

export BASEDIR=$(dirname $0)

cd ${BASEDIR}
for sub in $(grep -v ^# az_subscription.lst)
do
   bash az_login_${sub}.sh
   bash az_get_vm_Linux.sh
done
