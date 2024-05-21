#!/bin/bash
export BASEDIR=$(dirname $0)
#------------------------------------------------------
# check_Linux_pmx.sh
#------------------------------------------------------
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage() {
  echo "Usage: $0 -p PI_VERSION"
  echo ""
  echo "-p The PI Version"
  echo "This script Prepare a reports of all VMs and thier compliance with the PI version of various SW"
  echo "Example:"
  echo "   $0 -p PI29"
  exit 1
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {
  while getopts :p: opt; do
    case "$opt" in
    p) export PIVERSION=${OPTARG};;
    *) Usage ;;
    esac
  done
  [[ -z "${PIVERSION}" ]] && echo "PIVERSION is missing" && Usage
}
#
# MAIN
#
get_params $*

set -x

sudo bash /BD/GIT/aia-maintenance/self_git_pull.sh
tmpdir=/BD/PMX/$(date +%s)
sudo mkdir -p ${tmpdir}
scriptname=check_single_node_pmx.sh
sudo cp ${BASEDIR}/${scriptname} ${BASEDIR}/*.sed ${tmpdir}

for host in $(bash ${BASEDIR}/../GEN/get_hosts_list.sh)
do
  timeout 20 sudo ssh $host bash ${tmpdir}/${scriptname} > ${tmpdir}/pmx_${host}.out 2> ${tmpdir}/pmx_${host}.err &
done
ps -fe |grep ${scriptname}
wait
#ls -ld ${tmpdir}/pmx*

tmpcsv=${tmpdir}/all_pmx.csv

head -n 5 ${BASEDIR}/pmx_Linux.csv                       >> ${tmpcsv}
cat ${tmpdir}/pmx*out | sed 's/,/||/g' | sed 's/#/,/g' >> ${tmpcsv}
sed -i '/^$/d'  ${tmpcsv}

bash ${BASEDIR}/../GEN/gen_csv_to_html.sh -i ${tmpcsv}  -o ${tmpcsv}.html

cp ${tmpcsv} ${tmpcsv}.html .

echo errors:
sort -u ${tmpdir}/pmx*err

echo Report
sudo cp all_pmx.csv.html /var/www/html/
#echo ${BUILD_URL}/execution/node/3/ws/all_pmx.csv.html
echo http://aia-monitoring.eaas.KUKU.com/all_pmx.csv.html

