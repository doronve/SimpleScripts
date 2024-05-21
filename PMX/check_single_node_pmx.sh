#!/bin/bash
#
# Name: check_single_node_pmx.sh
#
# Description: provide information about current node
#
# FQDN , OS , JAVAVER , HELMVER , CDHVER , PSQLVER , RAVER , CASVER , SCYVER , DOCVER , KCTLVER , ESVER , ATTVER , ORAVER , JENSLAVE , MYSVER , MYCB , MYUSAGE
# 

export BASEDIR=$(dirname $0)
[[ ! -f /usr/sbin/lshw ]] && yum -y install lshw 2>/dev/null > /dev/null

FQDN=$(hostname -f)
OS=$(cat /etc/redhat-release | sed -f ${BASEDIR}/rhel.sed)
JAVAVER=$(java -version 2>&1 | grep version | sed -f ${BASEDIR}/java.sed)
#[[ -z "${JAVAVER}" ]] && JAVAVER="N/A"
HELMVER=""
for h in $(ls /usr/local/bin/helm* 2> /dev/null | tail -n 1)
do
  HELMVER="${HELMVER} $(${h} version --short|awk -F+ '{print $1}')"
done
#[[ -z "${HELMVER}" ]] && HELMVER="N/A"
CDHVER=$(ls -l /opt/cloudera/parcels/CDH      2>/dev/null | awk '{print $NF}'| sed 's/CDH-//' | awk -F- '{print $1}')
#[[ -z "${CDHVER}" ]] && CDHVER="N/A"
PSQLVER=$(psql --version                      2>/dev/null | head -n 1 | awk '{print $NF}' )
#[[ -z "${PSQLVER}" ]] && PSQLVER="N/A"
RAVER=$(rpm -qa |grep KUKU-fndsec-pki-ra-2.4.0.RELEASE-1.noarch | sed 's/KUKU-fndsec-pki-ra-//' | sed 's/.noarch//')
#[[ -z "${RAVER}" ]] && RAVER="N/A"
DOCVER=$(docker --version                     2>/dev/null | awk '{print $3}' | sed 's/,//' )
#[[ -z "${DOCVER}" ]] && DOCVER="N/A"
CASVER=$(cassandra -v 2> /dev/null)
#[[ -z "${CASVER}" ]] && CASVER="N/A"
SCYVER=$(scylla --version 2> /dev/null | awk -F- '{print $1}')
#[[ -z "${SCYVER}" ]] && SCYVER="N/A"
KCTLVER=$(kubectl version --client=true --short 2> /dev/null| awk '/Client/{print $NF}')
#[[ -z "${KCTLVER}" ]] && KCTLVER="N/A"
rpmtmpfile=$(mktemp)
rm -f $rpmtmpfile
rpm -qa | sort > ${rpmtmpfile}
ESVER=$(ls /usr/share/elasticsearch/lib/elasticsearch-*.jar 2> /dev/null | head -n 1 | sed 's/.jar//' | awk -F- '{print $NF}')
#[[ -z "${ESVER}" ]] && ESVER="N/A"
ATTVER=$(awk -F- '/areplicate/{print $2}' ${rpmtmpfile})
#[[ -z "${ATTVER}" ]] && ATTVER="N/A"
ORAVER=$(ls -d /oravl01/oracle/1*/lib 2> /dev/null| awk -F/ '{printf("%s ", $4)}END{print ""}')
#[[ -z "${ORAVER}" ]] && ORAVER="N/A"
JENSLAVE=$(java -jar /home/jenkins/remoting.jar -version 2> /dev/null)
#[[ -z "${JENSLAVE}" ]] && JENSLAVE="N/A"
MYSVER=$(awk -F- '/mysql-community-server/{print $2 "-" $4}/mysql-commercial-server/{print $2 "-" $4}/mysql-server/{print $3}' ${rpmtmpfile})
#[[ -z "${MYSVER}" ]] && MYSVER="N/A"
MYCB=$(/opt/couchbase/bin/couchbase-server --version 2> /dev/null| sed 's/Couchbase Server //g')
#[[ -z "${MYCB}" ]] && MYCB="N/A"
touch         ${HOME}/.DOUsage
MYUSAGE=$(cat ${HOME}/.DOUsage 2> /dev/null)
#[[ -z "${MYUSAGE}" ]] && MYUSAGE="N/A"

echo "${FQDN} # ${OS} # ${JAVAVER} # ${HELMVER} # ${CDHVER} # ${PSQLVER} # ${RAVER} # ${CASVER} # ${SCYVER} # ${DOCVER} # ${KCTLVER} # ${ESVER} # ${ATTVER} # ${ORAVER} # ${JENSLAVE} # ${MYSVER} # ${MYCB} # ${MYUSAGE} "
rm -f $rpmtmpfile $yumlistfile
