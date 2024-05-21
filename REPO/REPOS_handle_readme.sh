#!/bin/bash

repo=$1
[[ -z "${repo}" ]] && echo "Usage: $0 <repo>" && exit 1

READMEFILE=Readme.md

function checkParam(){
  param="$1"
  val="$2"
  grep -l "${param}:" ${READMEFILE}  > /dev/null
  if [ $? -ne 0 ]
  then
    echo "$repo,Missing param '${param}'" >> /tmp/${repo}.missing
    echo "* ${param}: ${val}" >> ${READMEFILE} 
  fi
  val=$(awk -F: "/${param}:/{print \$2}" ${READMEFILE} )
  [[ -z "${val}" || "${val}" = " " ]] && echo "$repo,Missing '${param}' value" >> /tmp/${repo}.missing
}

#git clone ssh://git@GITSERVER:7999/bda/${repo}.git
#cd $repo
touch ${READMEFILE} 
checkParam "Owner"
checkParam "Microservice Name" "$repo"
checkParam "Domain"            "$repo"
checkParam "Jenkins link"
checkParam "BitBucket"         "https://GITSERVER/projects/BDA/repos/${repo}/browse"
checkParam "Third Parties Dependencies"
checkParam "Type"

git add ${READMEFILE} 
git commit -am ${READMEFILE} 
git push
