#!/bin/bash


source ../../../env.sh

ENVIRONMENT="pdal-info"


aws batch update-compute-environment --compute-environment $ENVIRONMENT --state DISABLED

# wait for it to take effect
sleep $WAITFORIT
aws batch delete-compute-environment --compute-environment $ENVIRONMENT

