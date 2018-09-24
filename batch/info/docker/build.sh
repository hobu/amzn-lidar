#!/bin/bash


source ../../../env.sh
TAG=$(aws ecr describe-repositories| jq -r '.repositories[] | select( .repositoryName == "info") | .repositoryUri')

docker build --no-cache --pull -t $TAG .
docker push $TAG

