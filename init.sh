#!/bin/bash

source env.sh
docker pull 275986415235.dkr.ecr.us-west-2.amazonaws.com/info
#/bin/bash ./userdata/r53-register.sh
cd info/runner
python3 dequeue.py >>/mnt/pdalinfo/deqlog.log 2>&1
