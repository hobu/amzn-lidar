#!/bin/bash


source ../../../env.sh

ENVIRONMENT="pdal-info"

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

