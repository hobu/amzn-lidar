#!/bin/bash


#source ../../../env.sh

ENVIRONMENT="pdal-info"

RUN=$(aws ec2 run-instances --launch-template LaunchTemplateName="$ENVIRONMENT",Version=$Latest)
echo $RUN | jq -r


