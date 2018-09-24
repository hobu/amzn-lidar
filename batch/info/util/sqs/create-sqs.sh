#!/bin/bash


source ../../../../env.sh

ENVIRONMENT="pdal-info"

aws sqs delete-queue --queue-name $ENVIRONMENT

TMPENV=$(mktemp /tmp/temporary-sqs-pdal-info.XXXXXXXX)
cat > ${TMPENV} << EOF
{
    "QueueName": "$ENVIRONMENT",
    "Attributes": {
        "KeyName": ""
    }
}
EOF

aws sqs create-queue --cli-input-json file://"$TMPENV"

