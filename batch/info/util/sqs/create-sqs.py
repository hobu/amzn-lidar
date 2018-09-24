import boto3

# Get the service resource
sqs = boto3.resource('sqs', region_name='us-west-2')

queue = sqs.create_queue(QueueName='pdal-info')


