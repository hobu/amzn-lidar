#!/usr/bin/env python

import requests
import subprocess
import json
import os
import boto3
from botocore.errorfactory import ClientError
import sys

bucket = 'usgs-lidar'
s3_client = boto3.client('s3')
batch_client = boto3.client('batch')

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('pdal-info')


OVERWRITE=False
try:
    sys.argv[2]
    OVERWRITE=True
except:
    pass

paginator = s3_client.get_paginator( "list_objects" )
page_iterator = paginator.paginate(Bucket=bucket,
                                   Prefix = 'Projects/' ,
                                   RequestPayer='requester')


def get_folders(s3_client, bucket, prefix=''):
    paginator = s3_client.get_paginator('list_objects')
    for result in paginator.paginate(Bucket=bucket, Prefix=prefix, RequestPayer='requester',Delimiter='/'):
        for prefix in result.get('CommonPrefixes', []):
            yield prefix.get('Prefix')

def get_keys(s3_client, bucket, prefix=''):
    paginator = s3_client.get_paginator( "list_objects" )
    page_iterator = paginator.paginate(Bucket=bucket,
                                   Prefix = prefix,
                                   RequestPayer='requester')

    keys = []
    for page in page_iterator:
        for k in page['Contents']:
            keys.append(k['Key'])
    return keys

def checkExists(key):
    bucket = 'usgs-lidar-pdal-metadata'

    try:
        s3_client.head_object(Bucket=bucket, Key=key)
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            # The object does not exist.
            return False
        else:
            # Something else has gone wrong.
            raise
    return True

def didFail(key):
    response = table.get_item(Key={'Key':key})
    try:
        response['jobId']
    except KeyError:
        return False
    jobid = response['jobId']
    job = batch_client.describe_jobs(jobs=[jobid])
    for j in job['jobs']:
        if j['status'] == 'FAILED':
            return True
    return False

folders = get_folders(s3_client, bucket, prefix='Projects/%s/' % (sys.argv[1]))

for folder in folders:
    keys = get_keys(s3_client, bucket, folder)
    for key in keys:

        command = ['python','enqueue.py', key ]
	print command
        FAILED = didFail(key)

        EXISTS = checkExists(key+'.json')
        if OVERWRITE and EXISTS:
            WRITE = True
        elif FAILED:
            command.append('2048') # re-run with more memory
            WRITE=True
        else:
            WRITE = not EXISTS

        if WRITE:
            p = subprocess.Popen(command,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
            out, err = p.communicate()
            if (err):
                print (err)
            response = json.loads(out)
            dy = {}
            dy['jobId'] = response['jobId']
            dy['Key'] = key
            table.put_item(dy)

        else:
            print('key exists and not overwriting')
	#sys.exit()


#print (list(gen_folders))


