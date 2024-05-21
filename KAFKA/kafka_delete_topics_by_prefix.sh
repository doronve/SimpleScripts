#!/bin/bash
#
# Name: kafka_delete_topics_by_prefix.sh
# Description: Delete Kafka topics by prefix
#

#--------------------------------------
# function Usage
#--------------------------------------
function Usage() {
  msg="$1"
  echo "$msg"
  echo "Usage: $0 -p Prefix -c Cluster"
  echo ""
  echo "Example: $0 -p beitar -c cdp71-XXX-1"
  echo "  This will list all topics with prefix beitar_XXX in cluster cdp71-XXX-1"
  exit 1
}
#--------------------------------------
# function get_parameters
#--------------------------------------
function get_parameters()
{
echo function get_parameters

while getopts :p:c: opt
do
      case $opt in
         c) CLUSTER=$OPTARG
            ;;
         p) prefix=$OPTARG
            ;;
         *) Usage
            ;;
      esac
done
export MSG=""
[[ -z "$prefix" ]] && export MSG="Error: Missing prefix"
[[ -z "$CLUSTER" ]] && export MSG="${MSG} ; Error: Missing CLUSTER"
[[ "$CLUSTER" == "changeme" ]] && export MSG="${MSG} ; Error: Change CLUSTER Name from changeme !"
[[ ! -z "$MSG" ]] && Usage $MSG

}
get_parameters $*

export PATH=/BD/SW/Kafka/kafka_2.13-3.3.1/bin/:${PATH}
export KAFKA_HEAP_OPTS="-Xmx1G"
echo Total Number of Topics BEFORE =========
kafka-topics.sh --command-config KAFKA/${CLUSTER}_command-config.properties --list --bootstrap-server ${CLUSTER}:9093 | wc
echo ============ ALL TOPICS BY PREFIX ========
TOPICSLIST=$(kafka-topics.sh --command-config KAFKA/${CLUSTER}_command-config.properties --list --bootstrap-server ${CLUSTER}:9093 | grep ^${prefix}_)
# Iterate through the list of topics
for topic in ${TOPICSLIST}
do
   echo "count ACL for topic $topic - before delete"
         kafka-acls.sh --list --topic $topic --bootstrap-server ${CLUSTER}:9093 --command-config KAFKA/${CLUSTER}_command-config.properties | wc
         kafka-acls.sh --remove --force --topic ${topic} --bootstrap-server ${CLUSTER}:9093 --command-config KAFKA/${CLUSTER}_command-config.properties
   echo "count ACL for topic $topic - after delete"
         kafka-acls.sh --list --topic $topic --bootstrap-server ${CLUSTER}:9093 --command-config KAFKA/${CLUSTER}_command-config.properties | wc
  # Delete the topic
  echo kafka-topics.sh  --delete  --topic $topic  --bootstrap-server ${CLUSTER}:9093 --command-config KAFKA/${CLUSTER}_command-config.properties
  kafka-topics.sh --delete  --topic $topic  --bootstrap-server ${CLUSTER}:9093 --command-config KAFKA/${CLUSTER}_command-config.properties

   echo "count topics $topic - after delete"
   kafka-topics.sh --list --topic $topic  --bootstrap-server ${CLUSTER}:9093 --command-config KAFKA/${CLUSTER}_command-config.properties |  wc | awk '{print $2}'

done
echo Total Number of Topics AFTER =========
kafka-topics.sh --command-config KAFKA/${CLUSTER}_command-config.properties --list --bootstrap-server ${CLUSTER}:9093 | wc
