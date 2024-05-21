#!/bin/bash
#
# Name: check_single_node.sh
#
# Description: provide information about current node
#
# FQDN , Type, OS, MEM, CPU, Disks, last access, SW list/version: CDH, Cassandra, PostgreSQL, Docker, K8S
# 

export BASEDIR=`dirname $0`
[[ ! -f /usr/sbin/lshw ]] && yum -y install lshw 2>/dev/null > /dev/null

FQDN=`hostname -f`
HOSTTYPE=`lshw -short -c system | head -n 3 | tail -n 1 | sed 's/system//' | sed 's/^ *//' `

OS=`cat /etc/redhat-release`
MEM=`free -g | awk '/^Mem:/{print $2}'`
mCPU=`lscpu | awk '/^CPU.s./{print $NF}'`
LAST=`bash ${BASEDIR}/check_last.sh | head -n 1`
CDHVER=`ls -l /opt/cloudera/parcels/CDH      2>/dev/null | awk '{print $NF}'| sed 's/CDH-//' `
DOCVER=`docker --version                     2>/dev/null | awk '{print $3}' | sed 's/,//' `
PSQLVER=`psql --version                      2>/dev/null | head -n 1 | awk '{print $NF}' `
CASVER1=`nodetool version                    2>/dev/null`
num=`echo $CASVER1 | wc | awk '{print $3}'`
[[ $num -gt 50 ]] && CASVER1="ERROR"
CASVER=`echo $CASVER1                                    | sed 's/ReleaseVersion://' | sed 's/ //g' `

K8SVER=`kubectl version -o yaml              2>/dev/null | sed 's/"//g' | awk '/clientVersion/{AA="client";next}/serverVersion/{AA="server";next}/major/{mm=$2;next}/minor/{printf("%s:%s.%s ",AA,mm,$2);}' `
#ESVER=`/usr/share/elasticsearch/bin/elasticsearch --version  | awk '/Version:/{print $2}' | sed 's/,//'`
ESVER=`ls /usr/share/elasticsearch/lib/elasticsearch-*.jar | head -n 1 | sed 's/.jar//' | awk -F- '{print $NF}'`
rpmtmpfile=`mktemp`
rm -f $rpmtmpfile
rpm -qa | sort > ${rpmtmpfile}
JFROGVER=`awk -F- '/jfrog/{print $4}' ${rpmtmpfile}`
ORAVER=`ls -d /oravl01/oracle/1*/lib | awk -F/ '{printf("%s ", $4)}END{print ""}'`
JENSLAVE=`bash /BD/ggg/Monitor/check_jenkins_slave.sh 2> /dev/null`
MYSVER=`awk -F- '/mysql-community-server/{print $2 "-" $4}/mysql-commercial-server/{print $2 "-" $4}/mysql-server/{print $3}' ${rpmtmpfile}`
JENVER=`awk -F- '/jenkins/{print $2}' ${rpmtmpfile}`
JAVAVER=`java -version 2>&1 | grep version`
LSOF=`bash $BASEDIR/check_lsof.sh | awk '{printf("%s ",$1)}END{print ""}' | sed 's/......KUKU.com//' `
UPTIME=`uptime | awk '{print $3}'`

echo "${FQDN} # ${HOSTTYPE} # ${OS} # ${MEM} # ${mCPU} # ${UPTIME} # ${LAST} # ${CDHVER} # ${CASVER} # ${PSQLVER} # ${DOCVER} # ${K8SVER} # ${ESVER} # ${JFROGVER}  # ${ORAVER} # ${JENSLAVE} # ${MYSVER} # ${JENVER} # ${PONTIS} # ${JAVAVER} # ${LSOF} "
rm -f $rpmtmpfile $yumlistfile
