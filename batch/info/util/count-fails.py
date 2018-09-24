import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('pdal-info-error')

count = 0

response = table.scan()
data = response['Items']


print 'error count:', len(data)

import csv
with open('usgs-lidar-errors.csv', 'w') as csvfile:
    names=['Key']
    writer = csv.DictWriter(csvfile, delimiter=' ',fieldnames=names, quoting=csv.QUOTE_MINIMAL)
    writer.writeheader()
    for item in data:
        writer.writerow({'Key': item['Key']})



