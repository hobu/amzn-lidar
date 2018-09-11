ROLE="AmazonEC2SpotFleetRole"
S3POLICY="arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"

aws iam delete-service-linked-role \
    --role-name AWSServiceRoleForEC2Spot

aws iam delete-service-linked-role \
    --role-name AWSServiceRoleForEC2SpotFleet

aws iam detach-role-policy \
    --role-name $ROLE \
    --policy-arn $S3POLICY

aws iam delete-role \
    --role-name $ROLE

aws iam create-role \
    --role-name $ROLE \
    --description "Allow ECS spot fleet " \
    --assume-role-policy-document file://./policies/ecs-fleet-policy.json

aws iam attach-role-policy \
    --role-name $ROLE \
    --policy-arn $S3POLICY


aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
aws iam create-service-linked-role --aws-service-name spotfleet.amazonaws.com


