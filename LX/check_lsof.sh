#!/bin/bash

lsof -i -P|grep ESTA |awk '{print $(NF-1)}'|sed 's/->/ /'|awk '{print $1 "\n" $2}'|awk -F: '{print $1}'|sort -u | grep -v local | grep -v `hostname`
