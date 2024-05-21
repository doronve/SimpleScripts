#!/bin/bash
#------------------------------------------------------
# cre_00_gen_params.sh
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

#Generic Name
export GROUPNAME=${GENNAME}-rg
#Tags
export TAGS="CreatedBy=$(whoami);CreatedHost=$(hostname);CreatedDate=$(date +%Y%m%d_%H%M%S)"
#Subscription
export SUBSCRIPTION=$(az account list -o tsv|awk '/True/{print $3}')
##Network
#export ALLNET=$(az network vnet list -o tsv)
#KeyVault
export KVSKU=Standard
#Storage Account
export AMLDISPLAY=${GENNAME}-ws
export AMLNAME=${GENNAME}-ws

echo "#!/bin/bash
# Tags
export TAGS=\"${TAGS}\"
# Subscription
export SUBSCRIPTION=${SUBSCRIPTION}
# Generic Name
export GENNAME=\"${GENNAME}\"
# Group Name
export GROUPNAME=\"${GROUPNAME}\"
# Location
export LOCATION=\"${LOCATION}\"
#NetWork
export SUBNETID=\"${SUBNETID}\"
# Key Vault
export KVNAME=\"${KVNAME}\"
export KVID=\"${KVID}\"
export KVSKU=\"${KVSKU}\"
# Storage Account
export STANAME=\"${STANAME}\"
export STAID=\"${STAID}\"
export STASKU=\"Standard_RAGRS\"
#ACR
export ACRNAME=\"${ACRNAME}\"
export ACRID=\"${ACRID}\"
#APP
export APPNAME=\"${APPNAME}\"
export APPID=\"${APPID}\"
#AML
export AMLDISPLAY=\"${AMLDISPLAY}\"
export AMLNAME=\"${AMLNAME}\"
" > params.sh
