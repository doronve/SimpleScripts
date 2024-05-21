#!/bin/bash
#
# Name: get_hosts_list.sh
#
# Description: Sort all nodes from list of nodeslist.
#              Remove the remarked nodes and those in nodeexeptions.lst file
#              if the script gets any argument then all ESX servers are added to the list
#
# TODO: Set up a location of files

#
# clean up empty lines from nodeexeptions.lst
#
touch /BD/Monitor/nodeexeptions.lst 2> /dev/null
chmod +r /BD/Monitor/node*lst 2> /dev/null
sed -i 's/ //g'      /BD/Monitor/nodeexeptions.lst 2> /dev/null
sed -i 's/	//g' /BD/Monitor/nodeexeptions.lst 2> /dev/null
sed -i '/^$/d'       /BD/Monitor/nodeexeptions.lst 2> /dev/null

dos2unix /BD/Monitor/nodeexeptions.lst > /dev/null 2> /dev/null

Type="$1"

if [ ! -z "$Type" ]
then
sort -u /BD/Monitor/nodeslist_${Type}.lst |grep -v ^# | grep -x -v -f /BD/Monitor/nodeexeptions.lst
else
sort -u /BD/Monitor/nodeslist*.lst        |grep -v ^# | grep -x -v -f /BD/Monitor/nodeexeptions.lst
fi
