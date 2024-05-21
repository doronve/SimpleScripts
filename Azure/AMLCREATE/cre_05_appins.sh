#!/bin/bash

exit


source params.sh

az monitor app-insights component create --app             ${APPNAME}   \
                                         --location        ${LOCATION}  \
                                         --resource-group  ${GROUPNAME} \
                                         --application-type web         \
                                         --kind             web         \
                                         --retention-time   90          \
                                         --tags             ${TAGS}     \


exit


az monitor app-insights component create Y --app
                                         Y --location
                                         Y --resource-group
                                         Y [--application-type]
                                         N [--ingestion-access {Disabled, Enabled}]
                                         Y [--kind]
                                         N [--query-access {Disabled, Enabled}]
                                         Y [--retention-time]
                                         Y [--tags]
                                         N [--workspace]


