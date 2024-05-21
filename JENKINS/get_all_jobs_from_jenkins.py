#!/usr/bin/env python3
import ssl

#translate script to python
# Path: JENKINS/get_all_jobs_from_jenkins.py
# import requests
#import json
import urllib3

http = urllib3.PoolManager(
    cert_reqs="CERT_REQUIRED",
    ca_certs="/BD/Certs/JENKINSSERVER_ApsAtToolsJenkins.crt"
)

UUU='USER'
PPP='PASSWORD'
JURL='https://JENKINSSERVER:18081'

data=""
print("name,url,class")


try:
    response = http.request('GET', JURL+'/api/json', auth=(UUU, PPP))
    data = response.json()
  # response = requests.get(url=JURL+'/api/json', auth=(UUU, PPP),verify = False)
  # data = response.json()
except ssl.SSLCertVerificationError as Exception1:
  print ("error = " + str(Exception1))


for item in data['jobs']:
    print(item['name']+", "+item['url']+", "+item['_class'])
    if (item['_class']=='org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject'):
        JU2=JURL+'/job/'+item['name']+'/job/master/api/json'
        print("JU2 = " + JU2)
        try:
            response1=http.request('GET', JU2, auth=(UUU, PPP))
            data1 = response1.json()
            # response1 = requests.get(url=JU2, auth=(UUU, PPP),verify = False)
            # data1 = response1.json()
        except ssl.SSLCertVerificationError as Exception2:
            print ("error = " + str(Exception2))


# class = com.cloudbees.hudson.plugins.folder.Folder
# class = com.tikal.jenkins.plugins.multijob.MultiJobProject
# class = hudson.matrix.MatrixProject
# class = hudson.model.ExternalJob
# class = hudson.model.FreeStyleProject
# class = org.jenkinsci.plugins.pipeline.multibranch.defaults.PipelineMultiBranchDefaultsProject
# class = org.jenkinsci.plugins.workflow.job.WorkflowJob
# class = org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject

    #     print("color = " + data1['color'])
    #     print("fullName = " + data1['fullName'])
    #     print("inQueue = " + str(data1['inQueue']))
    #     print("buildable = " + str(data1['buildable']))
    #     print("nextBuildNumber = " + str(data1['nextBuildNumber']))
    #     print("property = " + str(data1['property']))
    #     print("healthReport = " + str(data1['healthReport']))
    #     print("queueItem = " + str(data1['queueItem']))
    #     print("lastBuild = " + str(data1['lastBuild']))
    #     print("lastCompletedBuild = " + str(data1['lastCompletedBuild']))
    #     print("lastFailedBuild = " + str(data1['lastFailedBuild']))
    #     print("lastStableBuild = " + str(data1['lastStableBuild']))
    #     print("lastSuccessfulBuild = " + str(data1['lastSuccessfulBuild']))
    #     print("lastUnstableBuild = " + str(data1['lastUnstableBuild']))
    #     print("lastUnsuccessfulBuild = " + str(data1['lastUnsuccessfulBuild']))
    #     print("builds = " + str(data1['builds']))
