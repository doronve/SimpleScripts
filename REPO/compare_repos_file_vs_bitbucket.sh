#!/bin/bash

export BASEDIR=$(dirname $0)

UUU=USER
PPP=PASSWORD
FLAGS="-k -X GET"
URL="https://GITSERVER/rest/api/1.0/projects/BDA/repos?limit=1000"

tmpfile=$(mktemp /tmp/all_repos_XXX.lst)
curl -u ${UUU}:${PPP} ${FLAGS} ${URL} | jq .values[].slug | sed 's/"//g' |grep -v -f ${BASEDIR}/repos_exceptions.lst | sort -u > $tmpfile

ls -ld $tmpfile

awk -F, '{print $2}' ${BASEDIR}/all_dataone_repos.csv | sort -u >  ${tmpfile}_from_csv

sdiff $tmpfile ${tmpfile}_from_csv
exit 0
