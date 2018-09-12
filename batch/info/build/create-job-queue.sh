#!/bin/bash


source ../../../env.sh

ENVIRONMENT="pdal-info"

aws batch update-job-queue --job-queue $ENVIRONMENT --state DISABLED
sleep $WAITFORIT;

aws batch delete-job-queue --job-queue $ENVIRONMENT
sleep $WAITFORIT;

aws batch create-compute-environment --cli-input-json file://"$TMPENV"

sleep $WAITFORIT


TMPJOBQUE=$(mktemp /tmp/temporary-job-queue.XXXXXXXX)
cat > ${TMPJOBQUE} << EOF
{
    "jobQueueName": "$ENVIRONMENT",
    "state": "ENABLED",
    "priority": 0,
    "computeEnvironmentOrder": [
        {
            "order": 0,
            "computeEnvironment": "$ENVIRONMENT"
        }
    ]
}
EOF

aws batch create-job-queue  --cli-input-json file://"$TMPJOBQUE"
sleep $WAITFORIT

