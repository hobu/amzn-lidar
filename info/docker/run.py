#!/usr/bin/env python

import requests
import subprocess
import json
import os
import sys
import boto3


try:

    input_file = os.environ['INPUT_FILE']
except KeyError:
    import sys
    print (sys.argv)
    input_file= sys.argv[1]

#    input_file="s3://usgs-lidar/Projects/USGS_LPC_PR_PuertoRico_2016_19QFA22006600_LAS_2017.laz"

s3 = boto3.resource('s3')


def refresh_tokens():
    url = 'http://169.254.169.254/latest/meta-data/iam/security-credentials/ecsInstanceRole'
    role = requests.get(url).text

    role = json.loads(role)

    os.environ['AWS_ACCESS_KEY_ID'] = role['AccessKeyId']
    os.environ['AWS_SESSION_TOKEN'] = role['Token']
    os.environ['AWS_SECRET_ACCESS_KEY'] = role['SecretAccessKey']
    os.environ['AWS_REQUESTER_PAYS'] = "1"
    os.environ['AWS_REGION'] = 'us-west-2'
    os.environ['OUTPUT_BUCKET'] = 'usgs-lidar-pdal-metadata'
    os.environ['AWS_ALLOW_INSTANCE_PROFILE'] = '1'
    os.environ['HOME'] = '/mnt/pdalinfo'
    #os.environ['CURL_VERBOSE'] = '1'

try:

    output_bucket = os.environ['OUTPUT_BUCKET']
except KeyError:
    output_bucket = 'usgs-lidar-pdal-metadata'

# pdal info -i $INPUT_FILE
# docker pull 275986415235.dkr.ecr.us-west-2.amazonaws.com/info:latest
# docker run 275986415235.dkr.ecr.us-west-2.amazonaws.com/info:latest s3://usgs-lidar/Projects/US_MexicanBorder_UTM14_2007/laz/US_MexicanBorder_UTM14_2007_000116.laz

input_bucket = input_file.split('/')[:3][2]
out_key = input_file.replace('s3://'+input_bucket+'/','')


refresh_tokens()

command = ['pdal','info',
                  input_file,
                  '--all',
                  '--readers.las.ignore_vlr="Merrick"']
p = subprocess.Popen(command,
                     stdout=subprocess.PIPE,
                     stderr=subprocess.PIPE)
out, err = p.communicate()

if out:
    pdal = json.loads(out)
    refresh_tokens()
    bucket = s3.Bucket(output_bucket).put_object(Key=out_key+'.json',
            Body=json.dumps(pdal), ContentType='application/json')
else:
    dynamodb = boto3.resource('dynamodb', region_name=os.environ['AWS_REGION'])
    table = dynamodb.Table('pdal-info-error')
    dy = {}
    dy['error'] = err
    dy['Key'] = out_key
    table.put_item(Item=dy)

