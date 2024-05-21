#!/bin/env groovy
def getAzAcct() {
[
'ACCOUNT',
'ACCOUNT2'
]
}
def venv=".testAzure"
env.venv=venv
pipeline {
  agent {label 'azure2'}
  options { 
    disableConcurrentBuilds()
    buildDiscarder(logRotator(daysToKeepStr: '2'))
  }
  parameters{
      choice(name: 'AZURE_ACCOUNT', choices: getAzAcct(), description: 'Choose Azure Account')
booleanParam(name: 'testKeyVault',  defaultValue: true,   description: 'Run Key Vault Test')
booleanParam(name: 'testStorage',   defaultValue: true,   description: 'Run Storage Test')
  }
  stages {
    stage('Check Azure Connection') {
      steps {
        script {
          sh '''
             source Azure/az_login_${AZURE_ACCOUNT}.sh
          '''
        }
      }
    }
    stage('Perp Python') {
      steps {
        script {
          sh '''
             bash Azure/prep_python.sh ${venv}
          '''
        }
      }
    }
    stage('Prep Config') {
      steps {
        script {
          sh '''
             echo bash Azure/prep_config.sh -m ${CHATGPT_MODEL} -u ${OPENAI_API_BASE} -v ${OPENAI_API_VERSION}
             echo bash Azure/prep_question.sh "${TheQuestion}"
          '''
        }
      }
    }
    stage('Test Key Vault') {
      when { expression { params.testKeyVault == true } }
      steps {
        script {
          sh '''
            set +x
            source ${venv}/bin/activate
            source ~/.proxy
            source Azure/az_login_${AZURE_ACCOUNT}.sh
            logfile=$(mktemp /tmp/kv_XXX.log)
            az keyvault list -o tsv 2>&1 | tee ${logfile}
            for name in $(awk '{print $3}' ${logfile})
            do
              export KEY_VAULT_NAME=$name
              echo KEY_VAULT_NAME=$KEY_VAULT_NAME
              python3 Azure/testKeyVault.py key$(date +%s) val$(date +%s)
            done
            rm -f ${logfile}
          '''
        }
      }
    }
    stage('Test Storage') {
      when { expression { params.testStorage == true } }
      steps {
        script {
          sh '''
            set +x
            source ${venv}/bin/activate
            source ~/.proxy
            source Azure/az_login_${AZURE_ACCOUNT}.sh
            logfile=$(mktemp /tmp/st_XXX.log)
            az storage account  list -o tsv --query [].name 2>&1 | tee ${logfile}
            for name in $(cat ${logfile})
            do
              export STORAGE_ACCOUNT_NAME=$name
              echo STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME
              python3 Azure/testStorage.py
            done
            rm -f ${logfile}
          '''
        }
      }
    }
  }
  post {
    success {
      echo 'I succeeded!'
    }
    failure {
      echo 'I Failed!'
    }
  }
}
