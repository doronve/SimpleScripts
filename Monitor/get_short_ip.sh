#!/bin/bash

hostname -i | awk -F. '{print $1 "." $2 "." $3}'

