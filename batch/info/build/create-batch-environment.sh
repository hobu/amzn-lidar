#!/bin/bash


source ../../../env.sh

ENVIRONMENT="pdal-info"


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
            "c5d.9xlarge",
            "c5d.4xlarge",
            "c5d.2xlarge",
            "c5d.xlarge",
            "c5d.large"
        ],
        "imageId": "ami-07b7e968c0d4eda53",
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

