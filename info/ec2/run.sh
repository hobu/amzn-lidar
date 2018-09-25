#!/bin/bash


#source ../../../env.sh

ENVIRONMENT="pdal-info"

ANUMBER=$((1 + RANDOM % 100))
NAME="pdalinfo-$ANUMBER"

INTERNAL="$NAME-internal"
EXTERNAL="$NAME-external"


ZONEID="uboh.io"
TAGS="ResourceType=instance,Tags=[{Key=internal-hostname,Value=$INTERNAL},{Key=external-hostname,Value=$EXTERNAL},{Key=dnszone,Value=$ZONEID},{Key=Name,Value=$NAME}]"

RUN=$(aws ec2 run-instances --launch-template LaunchTemplateName="$ENVIRONMENT",Version=$Latest --tag-specifications $TAGS)

echo $RUN | jq -r


