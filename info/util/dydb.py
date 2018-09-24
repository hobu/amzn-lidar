import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('pdal-info-error')

# table.put_item(
#         Item={'Key': "akey",
#               'JobId': "a job id"
#               })


import sys
resp = table.get_item(Key={'Key':sys.argv[1]})
import json
print json.dumps(resp)
