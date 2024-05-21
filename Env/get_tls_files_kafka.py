#!/usr/bin/env python3
import os
# import sys

#run linux script and get output into a variable
fpath=os.getcwd()
print(fpath)
def run_script(script):
    return os.popen(script).read()

hlist=run_script("bash /BD/GIT/aia-maintenance/GEN/get_hosts_list.sh")
print(hlist)

