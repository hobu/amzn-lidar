#!/bin/bash


source ../../../env.sh

ENVIRONMENT="pdal-info"


aws batch update-compute-environment --compute-environment $ENVIRONMENT --state DISABLED

# wait for it to take effect
sleep $WAITFORIT
aws batch delete-compute-environment --compute-environment $ENVIRONMENT

TMPENV=$(mktemp /tmp/temporary-batch-enviro.XXXXXXXX)
cat > ${TMPENV} << EOF
{
    "computeEnvironmentName": "$ENVIRONMENT",
    "type": "MANAGED",
    "state": "ENABLED",
    "computeResources": {
        "type": "SPOT",
        "minvCpus": 0,
        "maxvCpus": 256,
        "desiredvCpus": 0,
        "instanceTypes": [
            "c5.18xlarge",
            "c5.9xlarge",
            "c5.4xlarge",
            "c5.2xlarge",
            "c5.xlarge",
            "c5.large"
        ],
        "imageId": "",
        "subnets": [
            "subnet-04e6aab22265aab97",
            "subnet-05eb13a66a3f56abd",
            "subnet-0edd614ea6b3a97a1"
        ],
        "securityGroupIds": [
            "sg-0d45a196445af095f"
        ],
        "ec2KeyPair": "amzn-lidar-proc",
        "instanceRole": "ecsInstanceRole",
        "tags": {
            "KeyName": ""
        },
        "bidPercentage": 60,
        "spotIamFleetRole": "arn:aws:iam::275986415235:role/AmazonEC2SpotFleetRole"
    },
    "serviceRole": "ecsInstanceRole"
}
EOF

aws batch create-compute-environment --cli-input-json file://"$TMPENV"

