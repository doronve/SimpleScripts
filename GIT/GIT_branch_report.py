#!/usr/bin/env python37
import json
import os

# # url = "https://GITSERVER/rest/api/1.0/projects/BDA/repos?limit=1000"
# url = "https://GITSERVER/rest/api/1.0/projects/"
# user = "USER"
# pwd = "PASSWORD"

os.system("dir")

dflag="-D file.head.xml"
oflag="-o data.json"
cmd="curl -k -u USER:PASSWORD  -H 'Content-Type: application/json' -H 'Accept: application/json'  --url https://GITSERVER.corp.KUKU.com/rest/api/1.0/projects/BDA/repos?limit=1000 > data.json"
print(cmd)

os.system(cmd)

f = open('data.json')
data = f.read()
print(data)
# data = json.load(f)


# print(json.dumps(json.loads(output_file), sort_keys=True, indent=4, separators=(",", ": ")))








# import requests
# import json
# import ssl
# import urllib3
# import json
#
# #acces GITSERVER rest api
# # http = urllib3.PoolManager(
# #     cert_reqs="CERT_REQUIRED",
# #     ca_certs="c:\\CACERTS\\GITSERVER.corp.KUKU.com.crt"
# # )
# http = urllib3.PoolManager()
#
#
# headers = {
#     'Content-Type': 'application/json',
#     'Accept': 'application/json'
# }
# #Get repo list
# try:
#     # response = http.request("GET", url)
#     response = http.request("GET", url, headers=headers)
#     # response = http.request("GET", url, auth=(user, pwd))
#     print("response.status = " + str(response.status)) # 200 reponse means there is a connection
#     data=response.json()
#     # print(json.dumps(json.loads(response.text), sort_keys=True, indent=4, separators=(",", ": ")))
#     # data = response.json()
# except ssl.SSLCertVerificationError as Exception1:
#     print ("error = " + str(Exception1))
#
#
# #or if you have repos try this to print them
# #
# # #global variables
# # #GITSERVER server project
# # project = "BDA"
# # # #GITSERVER server repository
# # # repository = ""
# # # #GITSERVER server branch
# # # branch = ""
# # # #GITSERVER server pull request
# # # pullrequest = ""
# # # #GITSERVER server pull request reviewers
# # # reviewers = ""
# # # #GITSERVER server pull request approvers
# # # approv
# #
# #
# #
# #
