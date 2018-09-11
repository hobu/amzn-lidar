#!/usr/bin/env python

import requests
import subprocess
import json
import os
import boto3
import sys

bucket = 'usgs-lidar'
s3_client = boto3.client('s3')

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



folders = get_folders(s3_client, bucket, prefix='Projects/')

for folder in folders:
    keys = get_keys(s3_client, bucket, folder)
    for key in keys:

        command = ['python','enqueue.py', key ]
	print command
        p = subprocess.Popen(command,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE)
        out, err = p.communicate()
        if (err):
            print (err)
	#sys.exit()


#print (list(gen_folders))


