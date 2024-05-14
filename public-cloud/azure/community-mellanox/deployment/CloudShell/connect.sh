#!/bin/bash

while getopts i:k: flag
do
    case "${flag}" in
        i) PublicIp=${OPTARG};;
		k) SshKey=${OPTARG};;
    esac
done

chmod 400 $SshKey
ssh-keygen -R $PublicIp

# Copy Makefile to /home/ubuntu
ssh -o StrictHostKeyChecking=no -i $SshKey ubuntu@$PublicIp cp /home/ubuntu/otg-examples/public-cloud/azure/community-mellanox/deployment/Docker/Makefile /home/ubuntu/.

# Connect
ssh -o StrictHostKeyChecking=no -i $SshKey ubuntu@$PublicIp
