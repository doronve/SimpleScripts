#!/bin/bash
#
# Name: psql_get_single_data.sh
#

export PATH=/usr/local/bin:${PATH}
H=$(hostname)

DBLIST=$(export PGPASSWORD=postgres && psql -h $(hostname) -U postgres -w -c "\\l" 2>/dev/null |awk '/List of/{next}/Name/{next}/^-/{next}/^\(/{next}{print $1}' | grep -v "|")
[[ -z ${DBLIST} ]] && DBLIST="NA"
#[[ -z ${DBLIST} ]] && exit 0
DBLIST1=""
for db in ${DBLIST}
do
  DBLIST1="${DBLIST1} $db"
done

PSQLVER=$(psql --version| grep -v "contains support" | awk '{print $NF}')
#[[ -z ${PSQLVER} ]] && PSQLVER="NA"
[[ -z ${PSQLVER} ]] && exit 0
OSVER=$(cat /etc/redhat-release |\
  sed  's/Red Hat Enterprise Linux Server release /RHEL/' |\
  sed  's/ (Maipo)//'                                     |\
  sed  's/ (Santiago)//'                                  |\
  sed  's/Red Hat Enterprise Linux release /RHEL/'        |\
  sed  's/ (Ootpa)//'                                    )

NUMCPU=$(lscpu | awk '/^CPU\(s\):/{print $NF}')
NUMMEM=$(free -g | awk '/^Mem/{print $2}')

#
# Check if part of cloudera
#
CDHVER=""
rpm -qa |grep -l cloudera 2> /dev/null > /dev/null
[[ $? -eq 0 ]] && CDHVER=$(ls /opt/cloudera/parcels | grep -v CDH$ | awk -F- '/CDH/{print $2}')

echo "${H},${OSVER},${PSQLVER},${DBLIST1},${NUMCPU},${NUMMEM},${CDHVER}"
