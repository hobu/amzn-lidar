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


key=sys.argv[1]
MEMORY=256
try:
    MEMORY=sys.argv[2]
except:
    pass

name = key.split('.')[0].split('/')[-1]
key = 's3://' + bucket + '/'+ key
overrides = {
	"memory": 256,
	'command': ['%s'%key]
    }

response = batch.submit_job(jobName=name,
			jobQueue=queue,
			jobDefinition=definition,
			containerOverrides=overrides)
print (response)

