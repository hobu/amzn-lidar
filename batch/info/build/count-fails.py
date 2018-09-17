import boto3

def count (type):
    status = type
    queue = 'pdal-info'
    maxResults=100

    batch = boto3.client('batch')
    response = batch.list_jobs(jobQueue=queue, jobStatus=status, maxResults=maxResults)

    count = len(response['jobSummaryList'])
    while 'nextToken' in response:
        response = batch.list_jobs(jobQueue = queue,
                                   jobStatus = status,
                                   maxResults = maxResults,
                                   nextToken = response['nextToken'])
        count += len(response['jobSummaryList'])
    try:
        print (response['jobSummaryList'][0])
    except:
        pass
    return count

print ('SUBMITTED', count('SUBMITTED'))
print ('FAILED', count('FAILED'))
print ('RUNNABLE', count('RUNNABLE'))
print ('RUNNING', count('RUNNING'))
print ('SUCCEEDED', count('SUCCEEDED'))

