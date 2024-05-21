#!/bin/bash

export PSQLUSER=aiamonitor
export PSQLPASS=aiamonitor
export PSQLHOST=aia-monitoring.eaas.KUKU.com

#csvfile=$1
csvfile=/tmp/at40mynsrt_pods.csv_ilocpat402.csv

echo "insert into ocp_events values"
cp ${csvfile} ${csvfile}.new
sed -i 's/"http.*"/"http:\/\/xxx/' ${csvfile}.new
sed -i 's/volume "pvc-.*"/volume "pvc-xxx"/' ${csvfile}.new
sed -i 's/dial tcp .*:....: /dial tcp xx.xx.xx.xx:xxxx /' ${csvfile}.new
sed -i 's/volumes=.*:/volumes=[xxx]/' ${csvfile}.new
sed -i 's/volume ".*" :/ volume "xxx" :/' ${csvfile}.new
sed -i 's/secret ".*" not/ secret "xxx" not/' ${csvfile}.new
sed -i 's/persistentvolumeclaims ".*" not/persistentvolumeclaims "xxx" not/' ${csvfile}.new
sed -i 's/secretRef .* not/secretRef xxx not/' ${csvfile}.new
sed -i 's/are correct:.*)/are correct:[xxx)/'  ${csvfile}.new


awk -F, -v vv=\' '{print "(" vv $4 vv ", " vv $5 vv ", " vv $NF vv ")"}' ${csvfile}.new

