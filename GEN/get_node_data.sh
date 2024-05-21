#!/bin/bash
#
# Name: get node data
#
# Description: get node information in json format
#
touch /BD/a
[[ $? -ne 0 ]] && exit 1

export BASEDIR=`dirname $0`
[[ ! -f /usr/sbin/lshw ]] && yum -y install lshw 2>/dev/null > /dev/null
export MONITOR_DIR=/BD/Monitor
mkdir -p ${MONITOR_DIR}/HostsData

export FQDN=`hostname -f`
export SHORTNAME=`echo $FQDN | sed 's/.corp.KUKU.com//' | sed 's/.eaas.KUKU.com//'`
HOSTDIR=${MONITOR_DIR}/HostsData/${SHORTNAME}
mkdir -p ${HOSTDIR}

export HOSTTYPE=`lshw -short -c system | head -n 3 | tail -n 1 | sed 's/system//' | sed 's/^ *//' `
export MEM=`free -g | awk '/^Mem:/{print $2}'`
export mCPU=`lscpu | awk '/^CPU.s./{print $NF}'`
export OS=`cat /etc/redhat-release`
#
# Host Properties
#
echo "fqdn=${FQDN}
hostType=${HOSTTYPE}
OS=${OS}
Memory=${MEM}
CPU=${mCPU}" > ${HOSTDIR}/HostData.properties
#${CDHVER} ${HDPVER} ${MAPRVER} ${CASVER} ${PSQLVER} ${DOCVER} ${K8SVER}
${BASEDIR}/check_last.sh > ${HOSTDIR}/HostData.last
vmstat 1 3 > ${HOSTDIR}/HostData.vmstat
${BASEDIR}/check_ps.sh > ${HOSTDIR}/HostData.ps-fe
# keep 10 last files of lsof
nn=`ls -rt ${HOSTDIR}/HostData.lsof-i.*|tail -n 1 | awk -F\. '{print $NF}'`
if [ -z $nn ]
then
  qq=0
else
  let qq=$nn+1
  [[ $qq -eq 10 ]] && qq=0
fi
lsof -i > ${HOSTDIR}/HostData.lsof-i.$qq
bash /BD/LSI/check_disks.sh > ${HOSTDIR}/HostData.disks
ifconfig > ${HOSTDIR}/HostData.ifconfig

#
#SW
#
# rpm
rpm -qa | sort > ${HOSTDIR}/HostData.rpm
#CDH - ver, components, cluster members. TODO - currently, parcels only. should we check rpms?
[[ -f /etc/cloudera-scm-agent/config.ini ]] && CDHSERVER=`awk -F= '/server_host/{print \$2}' /etc/cloudera-scm-agent/config.ini`
if [ ! -z "$CDHSERVER" ]
then
  ls -l /opt/cloudera/parcels | awk '/ -> /{print $NF}' | sort -u > ${HOSTDIR}/HostData.CDH
  grep cloudera-manager ${HOSTDIR}/HostData.rpm                  >> ${HOSTDIR}/HostData.CDH
#  echo CDHSERVER=$CDHSERVER >> ${HOSTDIR}/HostData.CDH
#  export CDHVER=`ls -l /opt/cloudera/parcels/CDH      2>/dev/null | awk '{print $NF}'| sed 's/CDH-//' `
#  echo CDHVER=$CDHVER >> ${HOSTDIR}/HostData.CDH
fi
# HDP
ls /usr/hdp | grep -v current |grep -v share > ${HOSTDIR}/HostData.HDP
export HDPVER=`ls -l /usr/hdp/current/hadoop-client 2>/dev/null | awk '{print $NF}'| sed 's/.hadoop//' | sed 's/.usr.//' | sed 's/hdp.//' `
# MAPR
cat /opt/mapr/MapRBuildVersion > ${HOSTDIR}/HostData.MapR
export MAPRVER=`cat /opt/mapr/MapRBuildVersion      2>/dev/null`
# Cassandra
nodetool version > ${HOSTDIR}/HostData.Cassandra
export CASVER=`nodetool version                     2>/dev/null | sed 's/ReleaseVersion://' | sed 's/ //g' `
# Oracle
ls ~oracle > ${HOSTDIR}/HostData.Oracle
# PostGres
psql --version > ${HOSTDIR}/HostData.psql
export PSQLVER=`psql --version                      2>/dev/null | head -n 1 | awk '{print $NF}' `
#Mysql
mysql --version > ${HOSTDIR}/HostData.mysql
export MYSQLVER=`mysql --version                    2>/dev/null | head -n 1 | awk '{print $3}' `
#Couchbase
cat /opt/couchbase/VERSION.txt > ${HOSTDIR}/HostData.CouchBase
export CBVER=`cat /opt/couchbase/VERSION.txt     2>/dev/null `
#Docker
docker --version > ${HOSTDIR}/HostData.Docker
export DOCVER=`docker --version                     2>/dev/null | sed 's/Docker version//' `
#K8S
kubectl version -o yaml > ${HOSTDIR}/HostData.K8S
export K8SVER=`kubectl version -o yaml              2>/dev/null | sed 's/"//g' | awk '/clientVersion/{AA="client";next}/serverVersion/{AA="server";next}/major/{mm=$2;next}/minor/{printf("%s:%s.%s ",AA,mm,$2);}' `
echo Usage
vmstat -t 1 3 >> ${HOSTDIR}/HostData.vmstat
tail -n 100 ${HOSTDIR}/HostData.vmstat > ${HOSTDIR}/HostData.vmstat.100
mv -f ${HOSTDIR}/HostData.vmstat.100 ${HOSTDIR}/HostData.vmstat
mpstat 1 3 >> ${HOSTDIR}/HostData.mpstat
tail -n 100 ${HOSTDIR}/HostData.mpstat > ${HOSTDIR}/HostData.mpstat.100
mv -f ${HOSTDIR}/HostData.mpstat.100 ${HOSTDIR}/HostData.mpstat
echo access - , accum
echo in the family


#echo "${FQDN} # ${HOSTTYPE} # ${OS} # ${MEM} # ${mCPU} # ${LAST} # ${CDHVER} # ${HDPVER} # ${MAPRVER} # ${CASVER} # ${PSQLVER} # ${DOCVER} # ${K8SVER} "

