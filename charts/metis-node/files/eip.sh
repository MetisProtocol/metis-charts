#!/bin/bash

set -ex
set -o pipefail

yum update -y  && yum install -y jq

EIP_INFO=$(aws ec2 describe-addresses --filter Name=public-ip,Values=$1 | jq -r '.Addresses[0]')
if [[ $EIP_INFO == 'null' ]]; then
    echo "EIP $1 does not exits"
    exit 1
fi


MD_TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300"`

PUBLIC_IP_TO_DISASSOCIATE=$(curl -sS -H "X-aws-ec2-metadata-token: $MD_TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
if [[ $1 = $PUBLIC_IP_TO_DISASSOCIATE ]]; then
    echo "The $PUBLIC_IP_TO_DISASSOCIATE eip has been configed"
    exit 0
fi

REGION=$(curl -sS -H "X-aws-ec2-metadata-token: $MD_TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

ASSOCIATION_ID=$(jq -r '.AssociationId' <<<$EIP_INFO)

if [[ $ASSOCIATION_ID != 'null' ]]; then
    aws ec2 disassociate-address --association-id "$ASSOCIATION_ID" --region=$REGION
fi

ALLOCATION_ID=$(jq -r '.AllocationId' <<<$EIP_INFO)
INSTANCE_ID=$(curl -sS -H "X-aws-ec2-metadata-token: $MD_TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
NETWORK_INTERFACE_ID=$(aws ec2 describe-network-interfaces --filters Name=addresses.association.public-ip,Values=$PUBLIC_IP_TO_DISASSOCIATE --region=$REGION | jq '.NetworkInterfaces[] | {NetworkInterfaceId}' | jq -r '.NetworkInterfaceId')

aws ec2 associate-address --allocation-id "$ALLOCATION_ID" --network-interface-id "$NETWORK_INTERFACE_ID" --region=$REGION --no-allow-reassociation

echo "Done!"
