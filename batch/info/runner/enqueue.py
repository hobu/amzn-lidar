#!/usr/bin/env python

import requests
import subprocess
import json
import os
import boto3
import sys

bucket = 'usgs-lidar'
queue = 'pdal-info'
normal = 'pdal-info:6'
big= 'pdal-info-big:1'


batch = boto3.client('batch')
s3 = boto3.client('s3')

# key = 's3://' + bucket + '/'+ keys[0]


key = sys.argv[1]

ho = s3.head_object(Bucket=bucket, Key=key,  RequestPayer='requester')
size = (ho['ResponseMetadata']['HTTPHeaders']['content-length'])

# 35mb LAZ ~= 100mb LAS. PDAL uses 2x LAS size memory
if size > 34952534:
    definition= big
else:
    definition = normal
name = key.split('.')[0].split('/')[-1]
key = 's3://' + bucket + '/'+ key


overrides = {
	'command': ['%s'%key]
    }

response = batch.submit_job(jobName=name,
			jobQueue=queue,
			jobDefinition=definition,
			containerOverrides=overrides)

response = json.dumps(response)
sys.stdout.write(response)


