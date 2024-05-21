#!/bin/bash
#
# Name: cas_get_single_data.sh
#

export PATH=/usr/local/bin:${PATH}
H=$(hostname)

SYVER=$(rpm -qa |grep cassandra |grep -v cassandra-tools | sed 's/cassandra-//' | sed 's/.noarch//')
OSVER=$(cat /etc/redhat-release |\
  sed  's/Red Hat Enterprise Linux Server release /RHEL/' |\
  sed  's/ (Maipo)//'                                     |\
  sed  's/Red Hat Enterprise Linux release /RHEL/'        |\
  sed  's/ (Ootpa)//'                                    )
TLS=$(grep -v ^# /etc/cassandra/conf/cassandra.yaml |\
      grep -a1 client_encryption_options /etc/cassandra/conf/cassandra.yaml |\
      awk '/enabled:/{print $NF}')
[[ -z "${TLS}" ]] && TLS="none"
SSL=""
[[ "${TLS}" == "true" ]] && SSL="--ssl"
KSLIST=$(echo describe keyspaces | cqlsh $H ${SSL} | tr ' ' '\n' | sort | paste -s -d ' ')
ENCREST="No"
#grep -v ^# /etc/scylla/scylla.yaml | grep -a2 client_encryption_options |grep "enabled: true" 2>&1 > /dev/null
#[[ $? -eq 0 ]] && ENCREST="Yes"
[[ -z "${ENCREST}" ]] && ENCREST="No"
NUMCPU=$(lscpu | awk '/^CPU\(s\):/{print $NF}')
NUMMEM=$(free -g | awk '/^Mem/{print $2}')

echo "${H},${OSVER},${SYVER},${KSLIST},${TLS},${ENCREST},${NUMCPU},${NUMMEM}"
