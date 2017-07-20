#!/bin/bash


function Usage() {
  exitStatus=$1
  msg=$2
  echo "Usgae: $0 <properties file>"
  [[ ! -z "$msg" ]] && echo $msg
  exit $exitStatus
}

function setProperties() {
 cp ${propFile} ${propFile}.tmp
 sed -i 's/\t/ /g' ${propFile}.tmp
 sed -i 's/^ *//g' ${propFile}.tmp
 sed -i '/^#/d' ${propFile}.tmp
 sed -i 's/^/export /' ${propFile}.tmp
 source ${propFile}.tmp
}
function generatePom() {
  cp pom.xml.template newpom.xml
  sed -i 's/GROUPID/'$GROUPID'/'                     newpom.xml
  sed -i 's/ARTIFACTID/'$ARTIFACTID'/'               newpom.xml
  sed -i 's/VERSION/'$VERSION'/'                     newpom.xml
  sed -i 's/PACKNAME/'$PACKNAME'/'                   newpom.xml
  sed -i 's/NAME/'$NAME'/'                           newpom.xml
  sed -i 's:RPMINSTALLBASEDIR:'${RPMINSTALLBASEDIR}':' newpom.xml
  sed -i 's/GROUP/'$GROUP'/'                         newpom.xml
  sed -i 's:LOCATION:'$LOCATION':'                   newpom.xml
}

propFile=$1
[[ "$propFile" == "-h" ]] && Usage 0 "The properties file includes all relevant parameters for generating the pom.xml"
[[ ! -f $propFile      ]] && Usage 1 "no file"

env|sort > /tmp/env.1
setProperties
env|sort > /tmp/env.2
diff /tmp/env.?
generatePom
ls -l newpom.xml
