#!/bin/bash

BASEDIR=$(dirname $0)

UUU=USER
PPP=PASSWORD
JURL=https://JENKINSSERVER:18081

tmpfile=$(mktemp)

curl -s -X GET -u ${UUU}:${PPP} ${JURL}/api/json | tr ',' '\n,\n' > ${tmpfile}
grep url ${tmpfile} | grep job | sed 's/"url"://g' | sed 's/"//g' | sed 's/}$//g' | sed 's/\/$//' > ${tmpfile}.alljobs

sed -i '/checkmarx/d' ${tmpfile}.alljobs

#echo job,jenkinsfile,git > ${tmpfile}.csv
touch                       ${tmpfile}.csv
for f in $(cat ${tmpfile}.alljobs)
do
  j=$(echo $f | awk -F/ '{print $NF}')
  nohup curl -s -X GET -u ${UUU}:${PPP} ${f}/config.xml > ${tmpfile}.alljobs.${j} &
done
wait
for file in ${tmpfile}.alljobs.*
do
  git="";git1="";git2="";git3=""
  j=$(echo ${file} | awk -F\. '{print $NF}')
  jenkisfile=$(grep "<scriptPath>" ${file} |sed 's/</ /g' | sed 's/>/ /g'|awk '{print $2}')
  git1=$(       grep "<remote>"    ${file} |sed 's/</ /g' | sed 's/>/ /g'|awk '{print $2}')
  git2=$(      grep "<url>"        ${file} |sed 's/</ /g' | sed 's/>/ /g'|awk '{print $2}')
  git3=$(      grep "<repository>" ${file} |sed 's/</ /g' | sed 's/>/ /g'|awk '{print $2}')
  git=${git1}
  [[ -z "${git}" ]] && git=${git2}
  [[ -z "${git}" ]] && git=${git3}
  echo ${j},${jenkisfile},${git} | tee -a ${tmpfile}.csv
done

sed -i 's/ssh:..git.GITSERVER:7999.bda.//g' ${tmpfile}.csv
sed -i 's/.git$//g' ${tmpfile}.csv
sed -i 's/https:..GITSERVER.corp.KUKU.com.scm.bda.//g' ${tmpfile}.csv
sed -i 's/https:..GITSERVER.corp.KUKU.com.projects.BDA.repos.//g' ${tmpfile}.csv

ls -ld ${tmpfile}*

echo Job,JenkinsFile > ${tmpfile}_new.csv
awk -F, '{printf("<a href=\"https://JENKINSSERVER:18081/job/%s\" target=\"_blank\">%s</a></br>,<a href=\"https://GITSERVER.corp.KUKU.com/projects/BDA/repos/%s/browse/%s\" target=\"_blank\">%s</a></br>\n",$1,$1,$3,$2,$2)}' ${tmpfile}.csv >> ${tmpfile}_new.csv

sudo bash ${BASEDIR}/../GEN/gen_csv_to_html.sh -i ${tmpfile}_new.csv        -o /var/www/html/all_jobs_jenkinsfiles.html
