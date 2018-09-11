FROM pdal/ubuntu:master
MAINTAINER Howard Butler <howard@hobu.co>

RUN apt-get update -y && \
    apt-get install python-pip jq curl -y &&  \
    pip install awscli requests boto3


WORKDIR /tmp
USER nobody
ADD run.py /usr/bin/run.py

ENTRYPOINT ["/usr/bin/run.py"]


