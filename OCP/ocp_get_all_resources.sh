#!/bin/bash

export BASEDIR=$(dirname $0)
TMPDIR=$(mktemp -d)

for loginfile in ${BASEDIR}/my_oc_login_i*
do
  nohup bash ${BASEDIR}/ocp_get_all_resources_single_ocp.sh ${loginfile} ${TMPDIR} &
done
wait

ls -l $TMPDIR

