#!/bin/bash

export BASEDIR=$(dirname $0)

ls ${BASEDIR}/ |grep my_oc_login_i |grep -v old | sed 's/.sh$//' | sed 's/my_oc_login_//'

