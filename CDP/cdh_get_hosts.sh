#!/bin/bash
#
# Name: cdh_get_hosts.sh
#
# Description: get list of hosts from cloudera manager
#
#

export BASEDIR=`dirname $0`

myhomefile=$1
cdhhost=$2

tmpfile=/tmp/health_${cdhhost}_`date +%Y%m%d_%H%M%S`.tmp

  echo "<tr>"                                                                          >> ${myhomefile}.new.${cdhhost}
  echo "<td><IMG SRC=\"http://ilmtxbda73/myhome/images/cloudera-small.png\"></td>"     >> ${myhomefile}.new.${cdhhost}
  echo "<td><a href=\"http://${cdhhost}:7180\"  target=\"_blank\">${cdhhost}</a></td>" >> ${myhomefile}.new.${cdhhost}
  echo "<td>`${BASEDIR}/cdh_get_cluster_fullVersion.sh $cdhhost`</td>"                 >> ${myhomefile}.new.${cdhhost}
  echo "<td>`${BASEDIR}/cdh_get_cluster_displayName.sh $cdhhost`</td>"                 >> ${myhomefile}.new.${cdhhost}
  echo "<td>"                                                                          >> ${myhomefile}.new.${cdhhost}
  bash ${BASEDIR}/cdh_get_cluster_hosts.sh $cdhhost | sed 's/$/<br>/'                  >> ${myhomefile}.new.${cdhhost}
  echo "</td>"                                                                         >> ${myhomefile}.new.${cdhhost}
  echo "<td>"                                                                          >> ${myhomefile}.new.${cdhhost}
  ${BASEDIR}/cdh_get_cluster_health.sh $cdhhost                                        >> ${tmpfile}
  cat ${tmpfile}                                                                       >> ${myhomefile}.new.${cdhhost}
  echo "</td>"                                                                         >> ${myhomefile}.new.${cdhhost}
  echo "<td>"                                                                          >> ${myhomefile}.new.${cdhhost}
  ${BASEDIR}/get_yarn_stats.sh $cdhhost                                                 > ${tmpfile}.yarn
  cat ${tmpfile}.yarn  |sed 's/$/<br>/'                                                >> ${myhomefile}.new.${cdhhost}
  #timeout 10 ssh -o ConnectTimeout=3 $cdhhost sudo -u bdauser ${BASEDIR}/get_kafka_stats.sh $cdhhost                   > ${tmpfile}.kafka
  #cat ${tmpfile}.kafka |sed 's/$/<br>/'                                                >> ${myhomefile}.new.${cdhhost}
  ${BASEDIR}/get_hive_stats.sh $cdhhost ALL                                             > ${tmpfile}.hive
  cat ${tmpfile}.hive  |sed 's/$/<br>/'                                                >> ${myhomefile}.new.${cdhhost}
  ${BASEDIR}/get_hbase_stats.sh $cdhhost                                                > ${tmpfile}.hbase
  cat ${tmpfile}.hbase  |sed 's/$/<br>/'                                               >> ${myhomefile}.new.${cdhhost}
  ${BASEDIR}/get_hdfs_stats.sh $cdhhost                                                 > ${tmpfile}.hdfs
  cat ${tmpfile}.hdfs  |sed 's/$/<br>/'                                                >> ${myhomefile}.new.${cdhhost}
  echo "</td>"                                                                         >> ${myhomefile}.new.${cdhhost}
  echo "<td>"                                                                          >> ${myhomefile}.new.${cdhhost}
  bash ${BASEDIR}/get_env_type.sh $cdhhost                                             >> ${tmpfile}.envType
  cat ${tmpfile}.envType                                                               >> ${myhomefile}.new.${cdhhost}
  echo "</td>"                                                                         >> ${myhomefile}.new.${cdhhost}
  echo "<td>"                                                                          >> ${myhomefile}.new.${cdhhost}
  timeout 10 ssh -o ConnectTimeout=3 $cdhhost cat .DevOps/remarks                                 >> ${myhomefile}.new.${cdhhost}
  echo "</td>"                                                                         >> ${myhomefile}.new.${cdhhost}
  echo "</tr>"                                                                         >> ${myhomefile}.new.${cdhhost}

awk -v hh=$cdhhost '
NF==3&&$2!="GOOD"&&$2!="NOT_AVAILABLE"&&$2!="DISABLED"&&$2!="CONCERNING"{cnt++}END{if (cnt>0){printf("==\nPlease check cluster http://%s:7180 :\n",hh);}} ' $tmpfile   >> ${myhomefile}.mail.${cdhhost}
awk 'NF==3&&$2!="GOOD"&&$2!="NOT_AVAILABLE"&&$2!="DISABLED"&&$2!="CONCERNING"{print $1,$2}' $tmpfile                                                           >> ${myhomefile}.mail.${cdhhost}

rm -f ${tmpfile}*
