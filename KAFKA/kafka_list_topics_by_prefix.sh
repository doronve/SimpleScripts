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

# Get a list of all topics with the specified prefix
#topics=$(kafka-topics --list --bootstrap-server localhost:9092 | grep "^$prefix")
export PATH=/BD/SW/Kafka/kafka_2.13-3.3.1/bin/:${PATH}
num=$(kafka-topics.sh --command-config KAFKA/${CLUSTER}_command-config.properties --list --bootstrap-server ${CLUSTER}:9093 2> /dev/null | wc -l)
echo Total Number of Topics = $num
echo ============ ALL TOPICS BY PREFIX ========
num=$(kafka-topics.sh --command-config KAFKA/${CLUSTER}_command-config.properties --list --bootstrap-server ${CLUSTER}:9093 2> /dev/null | grep ^${prefix}_ | wc -l)
echo Total Number of Topics with prefix ${prefix} = $num
kafka-topics.sh --command-config KAFKA/${CLUSTER}_command-config.properties --list --bootstrap-server ${CLUSTER}:9093 2> /dev/null | grep ^${prefix}_
echo ==========================================
