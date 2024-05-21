#!/bin/bash
export MAX_CPU=65

export SENDMAIL="YES"
[[ ! -z "$1" ]] && export SENDMAIL="NO"

export PATH=/usr/local/bin:${PATH}
export csvfile=$(mktemp)
export URL=http://ilmtxbda73/ocp_all_avg.html
export myhtml=/var/www/html/ocp_all_avg.html
echo "Cluster,AVG CPU" > ${csvfile}

function check_ocp_cluster() {

cluster_name=$1

export KUBECONFIG=$(mktemp)
oc login https://${cluster_name} -u USER -p PASSWORD --insecure-skip-tls-verify 2>&1 > /dev/null
i=0
num_of_workers=$(oc get nodes | grep worker | wc -l )

tmpdir=$(mktemp -d)
for node  in $(oc get nodes | grep worker |awk '{print $1}')
do
   kubectl describe node ${node} | grep -A2 -e "^\\s*Resource"  | grep %  | awk '{print $3}' |sed "s/(//g" | sed "s/%)//g" > ${tmpdir}/${node} &
done

wait
let i=$(awk '{cnt+=$1}END{print cnt}' ${tmpdir}/*)
rm -rf ${tmpdir} ${KUBECONFIG}

let avg_cpu=${i}/${num_of_workers}

echo "The average CPU for OCP Cluster ${cluster_name} is $avg_cpu %"
export color_s=""
export color_e=""
MAILLIST="didevops@int.KUKU.com swapnil.patil5@KUKU.com"

if [[ $avg_cpu -gt ${MAX_CPU} ]]; then 
  export color_s='<b><font color="red">'
  export color_e='</font></b>'

  if [ "$SENDMAIL" == "YES" ]
  then
    for MAILTO in ${MAILLIST}
    do
      echo "!!!!!!!!!!!!! The CPU for OCP clutster '${cluster_name}' is '${avg_cpu}%' , its above the limit of ${MAX_CPU} !!!!!!!!!!!! ${URL}" | mailx -s "OCP cluster ${cluster_name} is more than ${MAX_CPU} ${URL}" ${MAILTO}
    done
  fi
fi   
echo "${cluster_name},${color_s}${avg_cpu}${color_e}" >> $csvfile
}

#
# Main
#
BASEDIR=$(dirname $0)


for ocp in $(bash ${BASEDIR}/get_ocp_list.sh)
do
  echo check_ocp_cluster "api.${ocp}.ocpd.corp.KUKU.com:6443"
  check_ocp_cluster "api.${ocp}.ocpd.corp.KUKU.com:6443"
done

bash ${BASEDIR}/../GEN/gen_csv_to_html.sh -i  ${csvfile} -o ${myhtml}

rm -rf ${csvfile}*
