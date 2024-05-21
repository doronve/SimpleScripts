#!/bin/bash

tmpfile=$(mktemp)
cd /var/lib/jenkins/jobs

awk '/git</{print FILENAME,$0}
     /scriptPath/' */config.xml > ${tmpfile}
sed -i 's/.config.xml//g'   ${tmpfile}
sed -i '/checkmarx/d'       ${tmpfile}
sed -i '/<defaultValue>/d'  ${tmpfile}
sed -i '/<description>/d'   ${tmpfile}
sed -i 's/<remote>//g'      ${tmpfile}
sed -i 's/<.remote>//g'     ${tmpfile}
sed -i 's/<url>//g'         ${tmpfile}
sed -i 's/<.url>//g'        ${tmpfile}
sed -i 's/<scriptPath>//g'  ${tmpfile}
sed -i 's/<.scriptPath>//g' ${tmpfile}
sed -E ':a ; $!N ; s/\n\s+/ / ; ta ; P ; D' ${tmpfile} > ${tmpfile}.1
mv -f ${tmpfile}.1 ${tmpfile}
sed -i 's/  */,/g' ${tmpfile}

ls -ld ${tmpfile}*

rm -f ${tmpfile}*
