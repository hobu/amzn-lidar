#!/bin/bash


#source ../../../env.sh

ENVIRONMENT="pdal-info"

aws ec2 delete-launch-template --launch-template-name "$ENVIRONMENT"

USERDATA64=$(cat user_data.txt | base64)

cat lt.json | jq -r '.UserData ="'$USERDATA64'"' > lt.load.json
aws ec2 create-launch-template \
    --launch-template-name "$ENVIRONMENT" \
    --launch-template-data file://lt.load.json \


