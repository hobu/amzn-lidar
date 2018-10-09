#!/bin/bash


DOCKERIMAGE="pdal/ubuntu:master"

function initialize
{
   repository=$1
   output=$(aws ecr create-repository --repository-name "$repository" )
   echo "created repository $repository"
   policy=$(cat ../policies/ecr-policy.json)
   output=$(aws ecr set-repository-policy --repository-name "$repository" --policy-text "$policy")
   repositories=$(aws ecr describe-repositories | jq -r .repositories[].repositoryName | tr " " "\n")
   echo "create: $output"

}


function list_repositories
{
    repositories=`aws ecr describe-repositories | jq -r .repositories[].repositoryName`
    repositories=$(echo $repositories| tr " " "\n")
echo $repositories
}

function wipe_repository
{
    repository="$1"
    echo "deleting $repository"
    images=`aws ecr list-images --repository-name $repository  | jq -r .imageIds[].imageTag |tr " " "\n"`
    echo "images: " $images
    for image in $images;
    do
        echo "listing images images: " $image
        deleted=$(aws ecr batch-delete-image --repository-name $repository --image-ids imageTag=\"$image\")


    done
    output=$(aws ecr delete-repository --repository-name "$repository" )
}

list_repositories
wipe_repository "pdal"

initialize "info"
initialize "coordinator"
initialize "worker"
