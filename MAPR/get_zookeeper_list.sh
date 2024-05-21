#!/bin/bash
#
# Name: get_zookeeper_list.sh
#
# Description: get the zookeeper hosts
#      CM - /run/cloudera-scm-agent/process/*-zookeeper-server/zoo.cfg
#      HDP - /etc/zookeeper/*/*/zoo.cfg
#      MAPR - /opt/mapr/zookeeper/zookeeper*/conf/zoo.cfg
#
# Input - $1 - the manager host 

host=$1

ZOOCFG=`timeout 10 ssh -o ConnectTimeout=3 $host ls -rt \
   /run/cloudera-scm-agent/process/*-zookeeper-server/zoo.cfg \
   /etc/zookeeper/*/*/zoo.cfg \
   /opt/mapr/zookeeper/zookeeper*/conf/zoo.cfg 2> /dev/null | tail -n 1`

[[ -z "$ZOOCFG" ]] && exit 1

ZKLIST1=`timeout 10 ssh -o ConnectTimeout=3 $host grep ^server $ZOOCFG | sed 's/^server..=//' | sed 's/:2888:3888/:2181/' | sed 's/:3181:4181/:2181/'`
ZKLIST=`echo $ZKLIST1 | sed 's/ /,/g'`

propfile=/BD/Monitor/${host}_properties.sh
touch $propfile
sed -i '/ZKLIST/d' $propfile
echo "export ZKLIST=$ZKLIST" >> $propfile

