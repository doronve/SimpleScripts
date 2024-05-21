#!/bin/bash

export BASEDIR=$(dirname $0)
export loginfile=$1
export tmpdir=$2
export KUBECONFIG=$(mktemp)

[[ -z "$loginfile" ]] && export loginfile=${BASEDIR}/my_oc_login_ilocpdo408.sh
[[ -z "$tmpdir"    ]] && export tmpdir=$(mktemp -d)

bash ${loginfile} > /dev/null 2> /dev/null
ocp=$(echo $loginfile | awk -F_ '{print $NF}'|sed 's/.sh//')

#vfile=${tmpdir}/${ocp}_verbs.lst
vfile=${BASEDIR}/ocp_verbs.lst

#kubectl api-resources --verbs=list --namespaced -o name  > $vfile
for ns in $(kubectl get ns -o name |grep -v -f ${BASEDIR}/namespace_blacklist.lst|sed 's/namespace.//')

do
  #kubectl get ns $ns
  for v in $(cat ${vfile})
  do
    nohup kubectl -n ${ns} get $v -o wide > ${tmpdir}/${ocp}_${ns}_${v}.lst 2> /dev/null &
  done
  #ps -fe |grep kubectl
  wait
done

#rm -f $vfile
ls -ld  $tmpdir/*
#rm -rf $tmpdir
#rm -rf $KUBECONFIG

