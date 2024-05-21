#!/bin/bash
#
# Name: run_hourly.sh
#
# Description: run hourly (via crontab) a set of other scripts
#
#

BASEDIR=`dirname $0`

HOURLYPIDFILE=/var/run/run_hourly.pid
if [[ -f $HOURLYPIDFILE ]]
then
 hpid=`cat $HOURLYPIDFILE`
 hourly=`ps -fp $hpid | grep hour`
 [[ $? -eq 0 ]] && echo "File $HOURLYPIDFILE exists. Exiting" && exit
 rm -f $HOURLYPIDFILE
fi
echo $$ > $HOURLYPIDFILE
echo `date` $0 $$ >> /tmp/cron_run_hourly_allruns.log

#
# Run hourly jobs
#
function func1_k8s_get_all_hosts() {
echo func1_k8s_get_all_hosts
echo    ${BASEDIR}/k8s_get_all_hosts.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/k8s_get_all_hosts.sh                      2>&1 >> /tmp/cron_k8s_get_all_hosts.log
}

function func2_check_OCP() {
echo func2_check_OCP
echo    ${BASEDIR}/check_OCP.sh       
echo    ==== `date`  ===============
#bash -x ${BASEDIR}/check_OCP.sh                              2>&1 >> /tmp/check_OCP.log
}

function func3_k8s_get_all_status_short() {
echo func3_k8s_get_all_status_short
echo    ${BASEDIR}/k8s_get_all_status_short.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/k8s_get_all_status_short.sh                     2>&1 >> /tmp/cron_get_df_all_hosts.log
}

function func4_get_df_all_hosts() {
echo func4_get_df_all_hosts
echo    ${BASEDIR}/get_df_all_hosts.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/k8s_get_all_status.sh                     2>&1 >> /tmp/cron_get_df_all_hosts.log
}

function func5_get_df_all_hosts() {
echo func5_get_df_all_hosts
echo    ${BASEDIR}/get_df_all_hosts.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/get_df_all_hosts.sh                       2>&1 >> /tmp/cron_get_df_all_hosts.log
}

function func6_cdh_get_all_hosts() {
echo func6_cdh_get_all_hosts
echo    ${BASEDIR}/cdh_get_all_hosts.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/cdh_get_all_hosts.sh                      2>&1 >> /tmp/cron_cdh_get_all_hosts.log
}

function func7_hdp_get_all_hosts() {
echo func7_hdp_get_all_hosts
echo    ${BASEDIR}/hdp_get_all_hosts.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/hdp_get_all_hosts.sh                      2>&1 >> /tmp/cron_hdp_get_all_hosts.log
}

function func8_mapr_get_all_hosts() {
echo func8_mapr_get_all_hosts
echo    ${BASEDIR}/mapr_get_all_hosts.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/mapr_get_all_hosts.sh                     2>&1 >> /tmp/cron_mapr_get_all_hosts.log
}

function func9_cb_get_all_hosts() {
echo func9_cb_get_all_hosts
echo    ${BASEDIR}/cb_get_all_hosts.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/cb_get_all_hosts.sh                       2>&1 >> /tmp/cron_cb_get_all_hosts.log
}

function func10_cas_get_all_hosts() {
echo func10_cas_get_all_hosts
echo    ${BASEDIR}/cas_get_all_hosts.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/cas_get_all_hosts.sh                      2>&1 >> /tmp/cron_cas_get_all_hosts.log
}

function func11_check_all_nodes_NFT() {
echo func11_check_all_nodes_NFT
echo    ${BASEDIR}/check_all_nodes.sh NFT
echo    ==== `date`  ===============
bash -x ${BASEDIR}/check_all_nodes.sh NFT                    2>&1 >> /tmp/cron_check_all_phys_disks.log
}

function func12_check_all_nodes() {
echo func12_check_all_nodes
echo    ${BASEDIR}/check_all_nodes_new.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/check_all_nodes_new.sh                        2>&1 >> /tmp/cron_check_all_phys_disks.log
echo    ${BASEDIR}/check_all_nodes.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/check_all_nodes.sh                        2>&1 >> /tmp/cron_check_all_phys_disks.log
}

function func13_check_all_phys_disks() {
echo func13_check_all_phys_disks
echo    ${BASEDIR}/check_all_phys_disks.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/check_all_phys_disks.sh                   2>&1 >> /tmp/cron_check_all_phys_disks.log
}

function func14_get_all_cluster_hosts_state_AUTO() {
echo func14_get_all_cluster_hosts_state_AUTO
echo    ${BASEDIR}/get_all_cluster_hosts_state.sh AUTO
echo    ==== `date`  ===============
bash -x ${BASEDIR}/get_all_cluster_hosts_state.sh AUTO       2>&1 >> /tmp/cron_get_all_hosts_AUTO.log
}

function func15_get_all_cluster_hosts_state_NFT() {
echo func15_get_all_cluster_hosts_state_NFT
echo    ${BASEDIR}/get_all_cluster_hosts_state.sh NFT
echo    ==== `date`  ===============
bash -x ${BASEDIR}/get_all_cluster_hosts_state.sh NFT        2>&1 >> /tmp/cron_get_all_hosts_NFT.log
}

function func16_get_all_cluster_hosts_state() {
echo func16_get_all_cluster_hosts_state
echo    ${BASEDIR}/get_all_cluster_hosts_state.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/get_all_cluster_hosts_state.sh            2>&1 >> /tmp/cron_get_all_hosts.log
}

function func17_get_all_cluster_hosts_state_short() {
echo func17_get_all_cluster_hosts_state_short
echo    ${BASEDIR}/get_all_cluster_hosts_state_short.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/get_all_cluster_hosts_state_short.sh      2>&1 >> /tmp/cron_get_all_cluster_hosts_short.log
}

function func18_check_all_vms() {
echo func18_check_all_vms
echo    ${BASEDIR}/check_all_vms.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/check_all_vms.sh                          2>&1 >> /tmp/cron_check_all_vms.log
}

#function func19_get_es_all_hosts() {
#echo func19_get_es_all_hosts
#echo    ${BASEDIR}/get_es_all_hosts.sh
#echo    ==== `date`  ===============
#bash -x ${BASEDIR}/get_es_all_hosts.sh                       2>&1 >> /tmp/cron_get_es_all_hosts.log
#}

function func20_check_all_uptime() {
echo func20_check_all_uptime
echo    ${BASEDIR}/check_all_uptime.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/check_all_uptime.sh                       2>&1 >> /tmp/cron_check_all_uptime.log
}

function func21_check_all_touchfile() {
echo func21_check_all_touchfile
echo    ${BASEDIR}/check_all_touchfile.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/check_all_touchfile.sh                    2>&1 >> /tmp/cron_check_all_touchfile.log
}

function func22_check_important_touchfile() {
echo func22_check_important_touchfile
echo    ${BASEDIR}/check_important_touchfile.sh
echo    ==== `date`  ===============
bash -x ${BASEDIR}/check_important_touchfile.sh              2>&1 >> /tmp/cron_check_important_touchfile.log
}

function func23_ocp_get_all_projects() {
echo func23_ocp_get_all_projects
echo    ${BASEDIR}/ocp_get_all_projects.sh
bash    ${BASEDIR}/ocp_get_all_projects.sh                   2>&1 >> /tmp/cron_ocp_get_all_projects.log
echo    ==== `date`  ===============
#timeout 10 ssh aia-oc-client-2 bash -x ${BASEDIR}/ocp_get_all_projects.sh                   2>&1 >> /tmp/cron_check_important_touchfile.log
#scp aia-oc-client-2:/var/www/html/ocp_projects.html /var/www/html/ocp_projects.html
}

function func24_ocp_get_all_pods_in_cluster() {
echo func24_ocp_get_all_pods_in_cluster
rm -f /tmp/cron_get_all_pods.log
touch /tmp/cron_get_all_pods.log
for clus in $(bash /BD/GIT/aia-maintenance/OCP/get_ocp_list.sh)
do
  echo clus=$clus 2>&1 >> /tmp/cron_get_all_pods.log
  bash -x /BD/GIT/aia-maintenance/OCP/ocp_get_all_pods_in_cluster.sh -c $clus -f /tmp/lll_$clus.csv 2>&1 >> /tmp/cron_get_all_pods.log
done
rm -f /tmp/lll*
}
function func25_get_all_az_vm() {
echo func25_get_all_az_vm
  bash -x /BD/GIT/aia-maintenance/Azure/az_get_vm_Linux_all_subs.sh > /tmp/cron_func25_get_all_az_vm1.log
  bash -x /BD/GIT/aia-maintenance/SCYLLA/az_scylla_get_version.sh   > /tmp/cron_func25_get_all_az_vm2.log
}
function func26_get_all_logs() {
echo func26_get_all_logs
  bash -x /BD/ggg/Monitor/loop_all_builds.sh > /tmp/cron_func26_get_all_logs.log
}
function func27_all_ocp_nodes_status() {
echo func27_all_ocp_nodes_status
  bash -x /BD/GIT/aia-maintenance/OCP/ocp_check_nodes.sh
}

rm -f /tmp/cron_time.log
touch /tmp/cron_time.log
time func1_k8s_get_all_hosts                                                 >> /tmp/cron_time.log
time func2_check_OCP                                                         >> /tmp/cron_time.log
time func3_k8s_get_all_status_short                                          >> /tmp/cron_time.log
time func4_get_df_all_hosts                                                  >> /tmp/cron_time.log
time func5_get_df_all_hosts                                                  >> /tmp/cron_time.log
time func6_cdh_get_all_hosts                                                 >> /tmp/cron_time.log
time func7_hdp_get_all_hosts                                                 >> /tmp/cron_time.log
time func8_mapr_get_all_hosts                                                >> /tmp/cron_time.log
time func9_cb_get_all_hosts                                                  >> /tmp/cron_time.log
time func10_cas_get_all_hosts                                                >> /tmp/cron_time.log
time func11_check_all_nodes_NFT                                              >> /tmp/cron_time.log
time func12_check_all_nodes                                                  >> /tmp/cron_time.log
time func13_check_all_phys_disks                                             >> /tmp/cron_time.log
time func14_get_all_cluster_hosts_state_AUTO                                 >> /tmp/cron_time.log
time func15_get_all_cluster_hosts_state_NFT                                  >> /tmp/cron_time.log
time func16_get_all_cluster_hosts_state                                      >> /tmp/cron_time.log
time func17_get_all_cluster_hosts_state_short                                >> /tmp/cron_time.log
time func18_check_all_vms                                                    >> /tmp/cron_time.log
#time func19_get_es_all_hosts                                                >> /tmp/cron_time.log
time func20_check_all_uptime                                                 >> /tmp/cron_time.log
time func21_check_all_touchfile                                              >> /tmp/cron_time.log
time func22_check_important_touchfile                                        >> /tmp/cron_time.log
time func23_ocp_get_all_projects                                             >> /tmp/cron_time.log
time func24_ocp_get_all_pods_in_cluster                                      >> /tmp/cron_time.log
time func25_get_all_az_vm                                                    >> /tmp/cron_time.log
time func26_get_all_logs                                                     >> /tmp/cron_time.log
time func27_all_ocp_nodes_status                                             >> /tmp/cron_time.log
bash /BD/GIT/aia-maintenance/OCP/check_ocp_cluster_cpu_threshold_mail.sh 2>&1 > /tmp/cron_threshold.log
bash /BD/GIT/aia-maintenance/OCP/ocp_get_nodes_stat.sh                   2>&1 > /tmp/cron_nodes.log

echo rm -f $HOURLYPIDFILE
rm -f $HOURLYPIDFILE
