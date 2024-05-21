#!/bin/bash

source ~/.proxy
export BASEDIR=$(dirname $0)

tmpfile=$(mktemp)

echo Subscription,VMName,Scylla Version > ${tmpfile}.csv
echo Subscription,NameSpace,Scylla IP   > ${tmpfile}_using.csv

for sub in $(grep -v ^# ${BASEDIR}/../Azure/az_subscription.lst)
do
  bash ${BASEDIR}/../Azure/az_login_${sub}.sh
  for ID in $(sort -u /BD/Monitor/AZ_nodeslist_*${sub}.lst)
  do
  #echo $ID
  vmname=$(echo $ID | awk -F/ '{print $NF}')
  nohup az vm run-command invoke --command-id RunShellScript \
                         --ids $ID \
                         --scripts "scylla --version" > ${tmpfile}_${sub}_${vmname}.out 2> ${tmpfile}_${sub}_${vmname}.err &
  done
  wait
  for f in ${tmpfile}_*.out
  do
    vmname=$(echo ${f} | awk -F_ '{print $NF}' | sed 's/.out//')
    msg=$(grep message ${f})
    [[ ! -z "${msg}" ]] && echo ${sub}, ${vmname} , ${msg} >> ${tmpfile}.csv
  done
#  ID=$(grep vm-ms360-automation$ /BD/Monitor/AZ_nodeslist_*${sub}.lst|sort -u | head -n 1)
#  cmd="sudo -u KUKU kubectl get svc  --all-namespaces|grep cass|grep Exter"
#  az vm run-command invoke --command-id RunShellScript \
#                         --ids $ID \
#                         --scripts "${cmd}" > ${tmpfile}_${sub}_scylla_usage.out 2> ${tmpfile}_${sub}_scylla_usage.err
#  sed -i 's/.....stderr...",//g'                            ${tmpfile}_${sub}_scylla_usage.out
#  sed -i 's/"message": "Enable succeeded: ...stdout...//g'  ${tmpfile}_${sub}_scylla_usage.out
#  awk '{gsub(/\\n/,"\n")}1' ${tmpfile}_${sub}_scylla_usage.out |awk -v sub=${sub}'{print sub "," $1 "," $5}' >> ${tmpfile}_using.csv

  #sed 's/\\n/\'$'\n''/g'                                    ${tmpfile}_${sub}_scylla_usage.out
done
#ls -ld ${tmpfile}.csv

sed -i '/command not found/d'                             ${tmpfile}.csv
sed -i 's/.....stderr...",//g'                            ${tmpfile}.csv
sed -i 's/"message": "Enable succeeded: ...stdout...//g'  ${tmpfile}.csv
bash ${BASEDIR}/../GEN/gen_csv_to_html.sh -i ${tmpfile}.csv -o /var/www/html/az_scylla.html
rm -f ${tmpfile}*
