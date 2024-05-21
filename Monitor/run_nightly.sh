#!/bin/bash
#
# Run Nightly Jobs
#

BASEDIR=`dirname $0`


bash  ${BASEDIR}/k8s_ocp_get_all_kafka_brokers.sh 2>&1 > /tmp/cron_k8s_ocp.log
#bash  /home/mstrnew/my_exp.sh              2>&1 > /tmp/cron_abckup_mstrnew.log
#bash  ${BASEDIR}/check_ilvbdsi.sh          2>&1 > /tmp/cron_check_ilvbdsi.log
bash  ${BASEDIR}/check_eaas.sh             2>&1 > /tmp/cron_check_eaas.log
bash  ${BASEDIR}/check_all_BD.sh           2>&1 > /tmp/cron_check_DB.log

bash /BD/GIT/aia-maintenance/self_git_pull.sh
bash /BD/GIT/aia-maintenance/OCP/ocp_get_all_pvc.sh
bash /BD/GIT/aia-maintenance/SCYLLA/scylla_get_all_hosts.sh
bash /BD/GIT/aia-maintenance/SCYLLA/scylla_get_all_keyspaces.sh
bash /BD/GIT/aia-maintenance/PSQL/psql_get_all_hosts.sh
bash /BD/GIT/aia-maintenance/PSQL/psql_get_all_databases.sh
bash /BD/GIT/aia-maintenance/GEN/delete_all_hprof.sh
bash /BD/GIT/aia-maintenance/GEN/check_all_crontab.sh
