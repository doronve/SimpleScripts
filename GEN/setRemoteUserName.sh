#!/bin/bash

prefix=$(hostname -i | awk -F\. '{print $1}')
export remoteUser=root

[[ "${prefix}" == "100" ]] && export remoteUser=KUKU

echo $remoteUser
