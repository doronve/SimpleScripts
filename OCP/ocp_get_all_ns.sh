#!/bin/bash
#
# ocp_get_all_ns.sh
#

export PATH=/usr/local/bin:${PATH}

ocp=$1
export KUBECONFIG=$(mktemp)
bash ./OCP/my_oc_login_${ocp}.sh 2> /dev/null > /dev/null
oc get projects -o custom-columns=NAME:.metadata.name | grep -v -f GEN/ocp_admin_projects.lst | grep -v NAME
rm -f $KUBECONFIG
