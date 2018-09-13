#!/bin/bash

unset AWS_SESSION_TOKEN
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
#unset AWS_PROFILE
unset AWS_DEFAULT_REGION

export AWS_DEFAULT_REGION="us-west-2"
#export AWS_PROFILE="amzn-lidar"

unset  AWS_SESSION_TOKEN
unset  AWS_SECRET_ACCESS_KEY
unset  AWS_ACCESS_KEY_ID
export WAITFORIT=20

AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r .Arn)
export AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID

aws_login=$(aws ecr get-login --no-include-email)

did_login=`$aws_login`
