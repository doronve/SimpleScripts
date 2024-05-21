#!/bin/bash
export BASEDIR=$(dirname $0)
export PATH=/usr/local/bin:${PATH}

OCH=$(whoami)
ocp=$(ls ./OCP/my*${OCH}*)
tmpfile=${PWD}/all_kb_${OCH}
bash ${ocp}
bash -x ${BASEDIR}/../Env/env_get_backing_services.sh $OCH > ${tmpfile}.csv.new 2> ${tmpfile}.err.new
oc logout
mv -f ${tmpfile}.csv     ${tmpfile}.csv.old
mv -f ${tmpfile}.err     ${tmpfile}.err.old
mv -f ${tmpfile}.csv.new ${tmpfile}.csv
mv -f ${tmpfile}.err.new ${tmpfile}.err

