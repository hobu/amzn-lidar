import boto3
from multiprocessing.pool import ThreadPool
from functools import partial
import json
import threading
from concurrent.futures import ProcessPoolExecutor
from concurrent.futures import ThreadPoolExecutor, wait, as_completed
import subprocess

import concurrent.futures
BUCKET='usgs-lidar'
CONTAINER='275986415235.dkr.ecr.us-west-2.amazonaws.com/info'
THREADS=80
BATCH_SIZE=10
DOIT = True

sqs = boto3.resource('sqs', region_name='us-west-2')
sqs_client = boto3.client('sqs', region_name='us-west-2')

queue = sqs.get_queue_by_name(QueueName='pdal-info')




def get_messages_from_queue():

    while True:
        resp = sqs_client.receive_message(
            QueueUrl=queue.url,
            AttributeNames=['All'],
            MaxNumberOfMessages=BATCH_SIZE
        )

        try:
            yield from resp['Messages']
        except KeyError:
            return

        entries = [
            {'Id': msg['MessageId'], 'ReceiptHandle': msg['ReceiptHandle']}
            for msg in resp['Messages']
        ]
#
        resp = sqs_client.delete_message_batch(
            QueueUrl=queue.url, Entries=entries
        )
#
        if len(resp['Successful']) != len(entries):
            raise RuntimeError(
                f"Failed telete messages: entries={entries!r} resp={resp!r}"
            )

keys = {}
def task(message):
    key = message['Body']
    full_key = 's3://'+BUCKET+'/'+key
    try:
        keys[key] += 1
        print ('duplicate')
        sys.exit()
    except KeyError:
        keys[key] = 1
    command = ['docker','run', '--rm',
                '--log-driver=awslogs',
                '--log-opt awslogs-region=us-west-2',
                '--log-opt awslogs-group=pdalinfo',
                '--log-opt awslogs-create-group=true',
                CONTAINER, full_key]
    print (command, "Task Executed {}".format(threading.current_thread()))
    if DOIT:
        p = subprocess.Popen(command,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE)
        out, err = p.communicate()
        if (err):
            print (err)
        sqs_client.delete_message(QueueUrl=queue.url,ReceiptHandle =message['ReceiptHandle'])




futures = []

with concurrent.futures.ProcessPoolExecutor(max_workers=THREADS) as executor:
    futures = []
    for resp in get_messages_from_queue():

        if (len(futures) == THREADS):
            print ('I am here')
            wait(futures)
            futures = []

        future = executor.submit(task, resp)
        futures.append(future)
