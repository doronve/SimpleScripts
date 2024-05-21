#!/bin/bash
#set -x
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy

export THIS_DIR="$(dirname -- "$(readlink -f -- "$0")")"
if [ -z "${WORKSPACE}" ] ; then 
        WORKSPACE=${THIS_DIR}
fi
export FILTEROUT='^NAME|^ibox|^openshift|^chi-live-env|^ci|^debug|^dedicated-admin|^default|^kube|^ms360-platform-crd|^ocp4-collectl|^openebs|^sparkns'

function tooOldNS()
{
  #OLDDAYS=30
  #OLDDAYS=60
  OLDDAYS=42
  echo OPC_Env=$OPC_Env
  tmpfile=$(mktemp /tmp/${OPC_Env}_old_XXXX)
  echo "$(date +%Y-%m-%d -d "${OLDDAYS} days ago") aaaaaaaDELDELDEL" > ${tmpfile}
  kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name} {.metadata.creationTimestamp} {"\n"}{end}'     | \
    egrep -v "${FILTEROUT}" | \
    sed 's/T..:..:..Z//' | awk '{print $2,$1}' >> ${tmpfile}
    sort -n ${tmpfile} > ${tmpfile}.s
  TODEL=$(grep -n aaaaaaaDELDELDEL ${tmpfile}.s | awk -F: '{print $1}')
  sed ''${TODEL}',$d' ${tmpfile}.s > ${tmpfile}.d
  ls -ld ${tmpfile}.d
  awk -v eee=$OPC_Env '{print eee "|" $1 "|" $2}' ${tmpfile}.d >> ${oldList}
  rm -f ${tmpfile}*
}

function emptyexpirationData()
{
  echo OPC_Env=$OPC_Env
  tmpfile=$(mktemp /tmp/${OPC_Env}_empty_XXXX)
  oc get projects -o yaml > ${tmpfile}
  egrep "   openshift.io/display-name:|^    name:"             ${tmpfile}   > ${tmpfile}.1
  awk '/display-name/{aa=$0;next}/ name:/{print $2,aa;aa="";}' ${tmpfile}.1 > ${tmpfile}.2
  egrep -v "${FILTEROUT}"                                      ${tmpfile}.2 > ${tmpfile}.3
  egrep -v "expiration_date"                                   ${tmpfile}.3 > ${tmpfile}.4
  awk -v PWD=${THIS_DIR} '{print "bash",PWD"/Set_Namespace_Experation_Date.sh",$1,"\""$1"\"";}' ${tmpfile}.4 > ${tmpfile}.5
  ls -ld  ${tmpfile}.5
  cat     ${tmpfile}.5
  bash -x ${tmpfile}.5
  rm -f ${tmpfile}*
}
#
# Update Expiration_Date on all Projects that created on the last 2 days
#
function updateFile()
{
  echo OPC_Env=$OPC_Env
  export updatefile=$(mktemp /tmp/${OPC_Env}_upd_XXXX)
  echo  "" > ${updatefile}

  echo kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name} {.metadata.creationTimestamp}{"\n"}{end}' 
  kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name} {.metadata.creationTimestamp}{"\n"}{end}' | egrep -v "${FILTEROUT}"
  kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name} {.metadata.creationTimestamp}{"\n"}{end}' 2> /dev/null | \
      egrep "`date +%Y-%m-%d`|`date +%Y-%m-%d -d "1 day ago"`" | \
      awk '{print "oc describe namespaces "$1"  |egrep  \"Name|display-name\" |paste -d \" \"  - -"}' > ${updatefile}
  ls -ld ${updatefile}
  echo =========== ${updatefile}
  cat ${updatefile}
  echo ===========
  bash ${updatefile}                        | \
     egrep -v "${FILTEROUT}"                | \
     sed 's/Name:        //g'               | \
     sed 's/openshift.io\/display-name=//g' | \
     awk -v PWD=${THIS_DIR}  '{print "bash "PWD"/Set_Namespace_Experation_Date.sh "$1" \""$2"\"";}' > ${updatefile}.sh
       
  chmod +x  ${updatefile}.sh 
  echo ===========
  ls -ld ${updatefile}.sh
  cat    ${updatefile}.sh
  echo ===========
  bash -x ${updatefile}.sh
  rm -f   ${updatefile}*
}
#
# Delete all Project that they Expiration_Date passed
#
function listDelete()
{

  oc describe namespaces  2> /dev/null | \
    egrep  "Name|display-name"         | \
    paste -d " "  - -                  | \
    egrep -v "${FILTEROUT}"            | \
    grep expiration_date               | \
    awk -v ENV=${OPC_Env} '{i=split($NF,ED,"=");split(ED[i],TS,"-");print ENV"|"$2"|"TS[1]TS[2]TS[3] }' >> ${deleteScript}
    grep -v NAMESPACES ./whitelist.txt |awk -v LIST=${deleteScript} '{print "sed /\^"$0"/d "LIST }' 
}

#
# Main Script Starts here
#


export CUR_DATE=`date +%Y%m%d`
export MAIL_DATE=`date +%Y%m%d -d "+2 days"`

export KUBECONFIG=${WORKSPACE}/.kube/config
mkdir -p ${WORKSPACE}/.kube

export oldList=$(mktemp /tmp/oldList_XXXX)
touch ${oldList}
export deleteScript=/tmp/deleteScript #$(mktemp)
touch ${deleteScript}

OPCList=("IND_AIANFT_401"  "ISR_AIA_401"  "ISR_AT_402"  "ISR_DO_401"  "ISR_PNTSNFT_402"  "ISR_PNTS_401"  "ISR_PNTS_403")

touch /tmp/mail.list
touch /tmp/mail.html
chmod +x ${deleteScript}

echo "" > ${deleteScript}
echo "" > /tmp/mail.list
echo "" > /tmp/mail.html

for OPC_Env in ${OPCList[@]}; do

  echo oc login https://api.${!OPC_Env}.ocpd.corp.KUKU.com:6443 -u USER -p XXXXXXXXXXXXXXXXX --insecure-skip-tls-verify # --config=${KUBECONFIG} 
  oc login https://api.${!OPC_Env}.ocpd.corp.KUKU.com:6443 -u USER -p PASSWORD --insecure-skip-tls-verify # --config=${KUBECONFIG} 

  tooOldNS
  emptyexpirationData
  updateFile
  listDelete

  echo oc logout  --insecure-skip-tls-verify # --config=${KUBECONFIG}
  oc logout  --insecure-skip-tls-verify # --config=${KUBECONFIG}
done

sed -ir '/^\s*$/d'  ${deleteScript}

awk -v CDate=${CUR_DATE} \
    -v PWD=${THIS_DIR} \
    -v Dfile="${deleteScript}.sh" \
    -F"|" '{if ($3 < CDate) {print PWD"/delete_ns.sh "$1" "$2"  ;sleep 15";}
           }' ${deleteScript} > ${deleteScript}.sh

awk -v MDate=${MAIL_DATE} \
    -F"|" '{if ($3 <=  MDate) {print $2,$1,$3;}
           }' ${deleteScript} >> /tmp/mail.list

chmod +x ${deleteScript}.sh
cat  ${deleteScript}.sh
bash ${deleteScript}.sh
sed -ir '/^\s*$/d' /tmp/mail.list
rm -f /tmp/mail.html
touch /tmp/mail.html

echo "<!DOCTYPE html>"                                                                >> /tmp/mail.html
echo "<html>"                                                                         >> /tmp/mail.html
echo "<head>"                                                                         >> /tmp/mail.html
echo "<style>"                                                                        >> /tmp/mail.html
echo "table,th,td"                                                                    >> /tmp/mail.html
echo "{"                                                                              >> /tmp/mail.html
echo "border:1px solid black;"                                                        >> /tmp/mail.html
echo "border-collapse:collapse;"                                                      >> /tmp/mail.html
echo "}"                                                                              >> /tmp/mail.html
echo "</style>"                                                                       >> /tmp/mail.html
echo "</head>"                                                                        >> /tmp/mail.html
echo "<Body>Hi All,<br><br>"                                                          >> /tmp/mail.html
if [ -s /tmp/mail.list ]
then
  echo "<u>The following Projects will be deleted in the next 72 hours:</u><br>"        >> /tmp/mail.html
  echo "<br><table><tr><td><b>Project Name</b></td><td><b>Cluster Name</b></td></tr>"   >> /tmp/mail.html
  awk '{print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 "</td></tr>"}' /tmp/mail.list >> /tmp/mail.html
  echo "</table><br>"                                                                   >> /tmp/mail.html
  echo "<b>If you wish to extend the expiration date please update the date on your project display-name annotation</b><br>" >> /tmp/mail.html
fi

#grep delete_ns ${deleteScript}.sh  | \
#   awk 'BEGIN{print "<br><u>The following Projects are now deleting:</u><br><br><br><br><table><tr><td><b>Project Name</b></td><td><b>Cluster Name</b></td></tr>"}
#        {print "<tr><td>" $3"</td><td>" $2"</td></tr>"}
#        END{print "</table><br>\n" }
#   '>> /tmp/mail.html

echo "<br><u>The following Projects are very Old. Please consider to Recreate them.</u>"                             >> /tmp/mail.html
echo "<br><br><table><tr><td><b>Cluster Name</b></td><td><b>Project Name</b><td><b>Creation Date</b></td></td></tr>" >> /tmp/mail.html
awk -F"|" '{print "<tr><td>"$1"</td><td>"$3"</td><td>"$2"</td></tr>"}'                                    ${oldList} >> /tmp/mail.html
echo "</table><br><br>"                                                                                              >> /tmp/mail.html
echo "<br>Regards,<br>DataOne DevOps team<br></Body></html>"                                                         >> /tmp/mail.html


rm -f /tmp/*_old_* /tmp/*_empty_* /tmp/*_upd_* /tmp/oldList_*





