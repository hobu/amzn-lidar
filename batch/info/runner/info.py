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
        s3_client.head_object(bucket, key)
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            # The object does not exist.
            return False
        else:
            # Something else has gone wrong.
            raise
    return True

folders = get_folders(s3_client, bucket, prefix='Projects/%s/' % (sys.argv[1]))

for folder in folders:
    keys = get_keys(s3_client, bucket, folder)
    for key in keys:

        command = ['python','enqueue.py', key ]
	print command

        EXISTS = checkExists(key+'.json')
        WRITE = (not EXISTS)
        if OVERWRITE and EXISTS:
            WRITE = True

        if WRITE:
            p = subprocess.Popen(command,
                                  stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
            out, err = p.communicate()
            if (err):
                print (err)
        else:
            print('key exists and not overwriting')
	#sys.exit()


#print (list(gen_folders))


