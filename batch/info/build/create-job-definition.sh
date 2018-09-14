#!/bin/bash


source ../../../env.sh

JOB_NAME="pdal-info-big"
CONTAINER="275986415235.dkr.ecr.us-west-2.amazonaws.com/info:latest"
MEMORY="4096"

#aws batch deregister-job-definition --job-definition $JOB_NAME
#sleep $WAITFORIT;


TMPJOB=$(mktemp /tmp/temporary-job.XXXXXXXX)
cat > ${TMPJOB} << EOF
{
    "jobDefinitionName": "$JOB_NAME",
    "type": "container",
    "parameters": {
        "KeyName": ""
    },
    "containerProperties": {
        "image": "$CONTAINER",
        "vcpus": 1,
        "memory": $MEMORY,
        "command": [
            "Ref::inputobject"
        ],
        "jobRoleArn": "arn:aws:iam::275986415235:role/ecsInstanceRole",
        "volumes": [ ],
        "environment": [
            {
                "name": "HOME",
                "value": "/tmp"
            }
        ],
        "mountPoints": [ ],
        "ulimits": [ ],
        "user": ""
    },
    "retryStrategy": {
        "attempts": 1
    },
    "timeout": {
        "attemptDurationSeconds": 360
    }
}
EOF


JOBID=$(aws batch register-job-definition --job-definition $JOB_NAME --type container --cli-input-json file://"$TMPJOB" | jq -r .jobDefinitionArn)


