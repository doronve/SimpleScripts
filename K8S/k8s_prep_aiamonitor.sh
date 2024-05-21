#!/bin/bash

adduser aiamonitor
bash /BD/ggg/change_root_passwd.sh aiamonitor aiamonitor
mkdir -p ~aiamonitor/.kube
cp /root/.kube/config ~aiamonitor/.kube
chown -R aiamonitor:aiamonitor ~aiamonitor/.kube

