ROLE="ecsInstanceRole"
S3POLICY="arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
LOGSPOLICY="ecs-put-logs"

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
    --description "Allow ECS execution" \
    --assume-role-policy-document file://./policies/ecs-policy.json

aws iam attach-role-policy \
    --role-name $ROLE \
    --policy-arn $S3POLICY

aws iam put-role-policy \
    --role-name $ROLE \
    --policy-name $LOGSPOLICY \
    --policy-document file://./policies/lambda_execution_log_policy.json



