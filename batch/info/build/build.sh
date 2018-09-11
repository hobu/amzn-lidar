#!/bin/bash


source ../env.sh
TAG=$(aws ecr describe-repositories| jq -r '.repositories[] | select( .repositoryName == "info") | .repositoryUri')

docker build --pull -t $TAG .
docker push $TAG
