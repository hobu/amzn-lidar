#!/bin/bash


source ../../../env.sh

ENVIRONMENT="pdal-info"

aws batch update-job-queue --job-queue $ENVIRONMENT --state DISABLED
sleep $WAITFORIT;

aws batch delete-job-queue --job-queue $ENVIRONMENT
sleep $WAITFORIT;

