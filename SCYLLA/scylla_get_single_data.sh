#!/bin/bash
#
# Name: scylla_get_single_data.sh
#

export PATH=/usr/local/bin:${PATH}
H=$(hostname)

export KSLIST=$(echo describe keyspaces | cqlsh $H 2> /dev/null | tr ' ' '\n' | sort | paste -s -d ' ')
[[ -z "${KSLIST}" ]] && export KSLIST=$(echo describe keyspaces | cqlsh $H --ssl | tr ' ' '\n' | sort | paste -s -d ' ')
SYVER=$(rpm -qa |grep scylla-enterprise-server | sed 's/scylla-enterprise-server-//' | sed 's/.x86_64//' |\
        awk -F\. '{print $1 "." $2 "." $3}')
OSVER=$(cat /etc/redhat-release |\
  sed  's/Red Hat Enterprise Linux Server release /RHEL/' |\
  sed  's/ (Maipo)//'                                     |\
  sed  's/Red Hat Enterprise Linux release /RHEL/'        |\
  sed  's/ (Ootpa)//'                                    )
TLS=$(grep -v ^# /etc/scylla/scylla.yaml | awk '/internode_encryption/{print $NF}')
[[ -z "${TLS}" ]] && TLS="none"
ENCREST="No"
grep -v ^# /etc/scylla/scylla.yaml | grep -a2 client_encryption_options |grep "enabled: true" 2>&1 > /dev/null
[[ $? -eq 0 ]] && ENCREST="Yes"
[[ -z "${ENCREST}" ]] && ENCREST="No"
NUMCPU=$(lscpu | awk '/^CPU\(s\):/{print $NF}')
NUMMEM=$(free -g | awk '/^Mem/{print $2}')

#[[ ! -z $KSLIST ]] && echo "${H},${OSVER},${SYVER},${KSLIST},${TLS},${ENCREST},${NUMCPU},${NUMMEM}"
echo "${H},${OSVER},${SYVER},${KSLIST},${TLS},${ENCREST},${NUMCPU},${NUMMEM}" | sed 's/   *//g'
