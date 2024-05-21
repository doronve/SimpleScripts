#!/bin/bash
export BASEDIR=$(dirname $0)

OCH=$(hostname)
tmpfile=${PWD}/all_kb_${OCH}
bash -x ${BASEDIR}/../Env/env_get_backing_services.sh $OCH > ${tmpfile}.csv.new 2> ${tmpfile}.err.new
mv -f ${tmpfile}.csv     ${tmpfile}.csv.old
mv -f ${tmpfile}.err     ${tmpfile}.err.old
mv -f ${tmpfile}.csv.new ${tmpfile}.csv
mv -f ${tmpfile}.err.new ${tmpfile}.err
