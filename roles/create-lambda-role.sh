ROLE="lambda_execution"
S3POLICY="arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
LOGSPOLICY="lambda-put-logs"

aws iam detach-role-policy \
    --role-name $ROLE \
    --policy-arn $S3POLICY

aws iam delete-role-policy \
    --role-name $ROLE \
    --policy-name $LOGSPOLICY \

aws iam delete-role \
    --role-name $ROLE

aws iam create-role \
    --role-name $ROLE \
    --description "allow execution of lambda" \
    --assume-role-policy-document file://./policies/lambda_execution_role_policy.json

aws iam attach-role-policy \
    --role-name $ROLE \
    --policy-arn $S3POLICY

aws iam put-role-policy \
    --role-name $ROLE \
    --policy-name $LOGSPOLICY \
    --policy-document file://./policies/lambda_execution_log_policy.json



