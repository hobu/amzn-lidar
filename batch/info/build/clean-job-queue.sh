#!/bin/bash


#source ../../../env.sh

ENVIRONMENT="pdal-info"

jobs=$(aws batch list-jobs --job-queue $ENVIRONMENT --job-status FAILED | jq  -c '.jobSummaryList')


for row in $(echo "${jobs}" | jq -c '.[]|.jobId'); do


    jobid=$(echo ${row} | jq -r '.')
echo "jobid:" $jobid
aws batch cancel-job --job-id "${jobid}" --reason "clean-job-queue.sh"

done


