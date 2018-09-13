#!/usr/bin/env python

import requests
import subprocess
import json
import os
import boto3
import sys

bucket = 'usgs-lidar'
queue = 'pdal-info'
definition = 'pdal-info:3'

batch = boto3.client('batch', region_name='us-west-2')

# key = 's3://' + bucket + '/'+ keys[0]

import os

MEMORY=256
try:
    attempts=os.environ['AWS_BATCH_JOB_ATTEMPT']
    if attempts > 1:
        MEMORY = 2048
except:
    pass

key=sys.argv[1]

name = key.split('.')[0].split('/')[-1]
key = 's3://' + bucket + '/'+ key
print (key, name)
overrides = {
	"memory": "%d"%MEMORY,
	'command': ['%s'%key]
    }

response = batch.submit_job(jobName=name,
			jobQueue=queue,
			jobDefinition=definition,
			containerOverrides=overrides)
print (response)

