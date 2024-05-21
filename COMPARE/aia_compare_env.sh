#!/bin/bash
#
# Name: aia_compare_env.sh
#
# Description: compare two aia environments
#   an environment is comprised of
#     - K8S
#       - Pods
#         - DataOne Pods
#         - Foundation Pods
#         - 3rd party Pods
#         - Backing services Pods
#       - Other resources
#     - Backing Services
#       - Kafka
#       - Scylla
#       - Snowflake
#       - PSQL
#       - ACR
#     - Other?
# 
#--------------------------------------
# function Usage
#--------------------------------------
function Usage() {
  msg="$1"
  echo "$msg"
  echo "Usage: $0 -t TYPE -n NAMESPACE1 -c CLUSTER1 -N NAMESPACE2 -C CLUSTER2 -r RESOURCES"
  echo "Example: $0 -t k8s -n ns1 -c c1-k8s-1 -N ns2 -C c2-k8s-1 -r podd,podf,kafka"
  echo " This will compare the two namespaces with pods of data one, foundation and the kafka"
  exit 1
}
#--------------------------------------
# function get_parameters
#--------------------------------------
function get_parameters()
{
echo function get_parameters

while getopts t:n:c:N:C:r: opt
do
      case $opt in
         t) TYPE=$OPTARG
            ;;
         n) NAMESPACE1=$OPTARG
            ;;
         c) CLUSTER1=$OPTARG
            ;;
         N) NAMESPACE2=$OPTARG
            ;;
         C) CLUSTER2=$OPTARG
            ;;
         r) RESOURCES=$OPTARG
            ;;
         *) Usage
            ;;
      esac
done
echo TYPE         = $TYPE
echo NAMESPACE1   = $NAMESPACE1
echo CLUSTER1     = $CLUSTER1
echo NAMESPACE2   = $NAMESPACE2
echo CLUSTER2     = $CLUSTER2
echo RESOURCES    = $RESOURCES
}
get_parameters $*

function compare_pods() {

}

