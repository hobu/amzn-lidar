#!/bin/bash

source  env.sh
docker pull 275986415235.dkr.ecr.us-west-2.amazonaws.com/info
./userdata/r53-register.sh
