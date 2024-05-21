#!/bin/bash
#------------------------------------------------------
# ocp_desc_all_projects.sh 
#------------------------------------------------------
#------------------------------------------------------
# function Usage
#------------------------------------------------------
function Usage() {
  echo "Usage: $0 -m CHATGPT_MODEL -u OPENAI_API_BASE -v OPENAI_API_VERSION"
  echo ""
  echo "-m for the Model"
  echo "-u for the openai URL"
  echo "-v for the API Version"
  echo "Example:"
  echo "   $0 -m CHATGPT_MODEL -u OPENAI_API_BASE -v OPENAI_API_VERSION"
  exit 1
}

#------------------------------------------------------
# function get_params
#------------------------------------------------------

function get_params() {

export CHATGPT_MODEL='gpt-35-turbo-0301'
export OPENAI_API_BASE='https://OPENAI.openai.azure.com/'
export OPENAI_API_VERSION='2023-03-15-preview'

  while getopts :m:u:v: opt; do
    case "$opt" in
    m) export CHATGPT_MODEL="$OPTARG" ;;
    u) export OPENAI_API_BASE="$OPTARG" ;;
    v) export OPENAI_API_VERSION="$OPTARG" ;;
    *) Usage ;;
    esac
  done
}
#
# MAIN
#
get_params $*

echo "{
    \"CHATGPT_MODEL\":\"${CHATGPT_MODEL}\",
    \"OPENAI_API_BASE\":\"${OPENAI_API_BASE}\",
    \"OPENAI_API_VERSION\":\"${OPENAI_API_VERSION}\"
}" > config.json
