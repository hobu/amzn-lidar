#!/bin/bash

# Assign route 53 based on instance tagso

sudo yum update -y;
sudo yum install python-pip27 jq
sudo pip install awscli

IDENTITY=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document)
REGION=$(echo $IDENTITY | jq -r .region)
echo $REGION

INSTANCE_ID=$(echo $IDENTITY | jq -r .instanceId)
echo $INSTANCE_ID

TAGS=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region $REGION)

DNS_INTERNAL=$(echo $TAGS | jq -r '.Tags[] | select (.Key == "internal-hostname" ) | .Value')
DNS_EXTERNAL=$(echo $TAGS |jq -r '.Tags[] | select (.Key == "external-hostname" ) | .Value')
ZONE=$(echo $TAGS | jq -r '.Tags[] | select (.Key == "dnszone") | .Value')
echo $ZONE

Q=".HostedZones[] | select (.Name == \"${ZONE}.\") | .Id'"
#echo $Q
ZONEID=$(aws route53 list-hosted-zones|jq -r --arg ZONE "$ZONE." '.HostedZones[] | select (.Name == $ZONE) | .Id'  |cut -d '/' -f 3)
echo "zoneid: " $ZONEID

PUBLIC_IPV4=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
LOCAL_IPV4=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
echo $PUBLIC_IPV4
echo $LOCAL_IPV4

TMPADDS=$(mktemp /tmp/temporary-file.XXXXXXXX)
cat > ${TMPADDS} << "EOF"
{
        "Comment": "CREATE",
        "Changes": [{
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                                "Name": "$DNS_EXTERNAL.$ZONE",
                                "Type": "A",
                                "TTL": 60,
                                "ResourceRecords": [{
                                        "Value": "$PUBLIC_IPV4"
                                }]
                        }
                },
                {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                                "Name": "$DNS_INTERNAL.$ZONE",
                                "Type": "A",
                                "TTL": 60,
                                "ResourceRecords": [{
                                        "Value": "$LOCAL_IPV4"
                                }]
                        }
                }
        ]
}
EOF
adds=$(aws route53 change-resource-record-sets --hosted-zone-id $ZONEID --change-batch file://"$TMPADDS")

rm $TMPADDS






