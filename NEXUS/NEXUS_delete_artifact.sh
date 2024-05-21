#!/bin/bash

UUU=USER
PPP=PASS
#URL=http://myNexus/service/local/repositories/myRepository/content/myGroupId/myArtifactId/myVersion
#URL=https://NEXUS_SERVER:28081/service/rest/repository/browse/maven-snapshots/com/KUKU/ml/sdk/azureml-sdk-parent/TRUNK-SNAPSHOT/TRUNK-20231004.105024-1
#URL="https://NEXUS_SERVER:28081/#browse/browse:maven-snapshots:com%2FKUKU%2Fml%2Fsdk%2Fazure_ml_sdk_base_image%2FTRUNK-SNAPSHOT%2FTRUNK-20231004.134747-3/"
#URL=https://NEXUS_SERVER:28081/service/local/repositories/maven-snapshots/com/KUKU/ml/sdk/azureml-sdk-parent/TRUNK-SNAPSHOT
URL="https://NEXUS_SERVER:28081/repository/maven-snapshots/com/KUKU/ml/sdk/azureml-sdk-parent/TRUNK-SNAPSHOT/"
#file=TRUNK-20231004.110443-3
file="azureml-sdk-parent-TRUNK-20231004.110443-3.pom"

echo curl -v --request DELETE --user "${UUU}:${PPP}" "${URL}/${file}"
echo $?


