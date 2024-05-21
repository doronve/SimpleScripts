#!/bin/bash
#------------------------------------------------------
# cre_00_all.sh
#------------------------------------------------------
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage() {
  echo "Usage: $0 -n Name -i <Subnet Id> [-k <KeyVault Id>] [-s <Storage Account Id>] [-a <ACR Id>] [-m <Monitor Insight Id>] [-l <Location>]"
  echo ""
  echo "-n for the Name of the Workstation (mandatory)"
  echo "-i for the Subnet ID (long path)   (mandatory)"
  echo "-k for the Key Vault ID (long path) (if not provided will crete a new one)"
  echo "-s for the Storage Account ID (long path) (if not provided will crete a new one)"
  echo "-a for the ACR ID (long path) (if not provided will crete a new one)"
  echo "-m for the Application Insight ID (long path) (if not provided will crete a new one)"
  echo "-l Location. default is northeurope"
  echo "Example:"
  echo "   $0 -n ws01 -i subnetId -k kvId -s staId -a acrId -m MonId"
  exit 1
}
#------------------------------------------------------
# function get_params
#------------------------------------------------------
function get_params() {

#Location
  export LOCATION=northeurope
  export KVEXSIST=false
  export STAEXSIST=false
  export ACREXSIST=false
  export APPEXSIST=false

  while getopts :n:i:k:s:a:m:l: opt; do
    case "$opt" in
    n) export GENNAME="$OPTARG" ;;
    i) export SUBNETID="$OPTARG" ;;
    k) export KVID="$OPTARG"  && export KVEXSIST=true ;;
    s) export STAID="$OPTARG" && export STAEXSIST=true ;;
    a) export ACRID="$OPTARG" && export ACREXSIST=true ;;
    m) export APPID="$OPTARG" && export APPEXSIST=true ;;
    l) export LOCATION="$OPTARG" ;;
    *) Usage ;;
    esac
  done
  [[ -z "${GENNAME}"  ]] && Usage
  [[ -z "${SUBNETID}" ]] && Usage
  [[ -z "${KVID}"   ]] && export KVNAME=${GENNAME}-kv
  [[ -z "${STAID}"  ]] && export STANAME=$(echo ${GENNAME}-sta | sed 's/-//g')
  [[ -z "${ACRID}"  ]] && export ACRNAME=$(echo ${GENNAME}-acr | sed 's/-//g')
  [[ -z "${APPID}"  ]] && export APPNAME=${GENNAME}-app
}
get_params $*

timestamp=$(date +%Y%m%d_%H%M%S)
echo cre_00_gen_params.sh
bash -x cre_00_gen_params.sh        2>&1 | tee cre_00_gen_params_${timestamp}.log
echo cre_01_rg.sh
bash -x cre_01_rg.sh                2>&1 | tee cre_01_rg_${timestamp}.log
[[ ! ${KVEXSIST} ]] && echo cre_02_kv.sh
[[ ! ${KVEXSIST} ]] && bash -x cre_02_kv.sh
[[ ! ${STAEXSIST} ]] && echo cre_03_storage_account.sh
[[ ! ${STAEXSIST} ]] && bash -x cre_03_storage_account.sh   2>&1 | tee cre_03_storage_account_${timestamp}.log
[[ ! ${ACREXSIST} ]] && echo cre_04_acr.sh
[[ ! ${ACREXSIST} ]] && bash -x cre_04_acr.sh               2>&1 | tee cre_04_acr_${timestamp}.log
[[ ! ${APPEXSIST} ]] && echo cre_05_appins.sh
[[ ! ${APPEXSIST} ]] && bash -x cre_05_appins.sh            2>&1 | tee cre_05_appins_${timestamp}.log
echo cre_06a_amlws.sh
bash -x cre_06a_amlws.sh            2>&1 | tee cre_06a_amlws_${timestamp}.log
echo cre_07a_amlcc.sh
bash -x cre_07a_amlcc.sh            2>&1 | tee cre_07a_amlcc_${timestamp}.log
#bash cre_07_amlcc.sh
#bash cre_07b_amlci.sh

ls -lrtd *${timestamp}*
