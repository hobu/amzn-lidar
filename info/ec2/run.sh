#!/bin/bash


#source ../../../env.sh

ENVIRONMENT="pdal-info"

INTERNAL="pdalinfo"
EXTERNAL="pdalinfo"

ZONEID="uboh.io"
TAGS="ResourceType=instance,Tags=[{Key=internal-hostname,Value=$INTERNAL},{Key=external-hostname,Value=$EXTERNAL},{Key=dnszone,Value=$ZONEID}]"

RUN=$(aws ec2 run-instances --launch-template LaunchTemplateName="$ENVIRONMENT",Version=$Latest --tag-specifications $TAGS)

echo $RUN | jq -r


