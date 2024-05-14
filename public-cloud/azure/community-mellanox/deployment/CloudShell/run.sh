#!/bin/bash

while getopts i: flag
do
    case "${flag}" in
        i) PublicIp=${OPTARG};;
    esac
done

# Copy the Makefile to the agent home directory (to be able to quickly run tests after make connect)
rm -f SshKey.pem
terraform output -state ../Terraform/terraform.tfstate SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" | tee SshKey.pem > /dev/null
chmod 400 SshKey.pem
IP=$(terraform output -state ../Terraform/terraform.tfstate -json Agent1Eth0PublicIpAddress | jq -r .fqdn)
ssh -i SshKey.pem ubuntu@$IP cp /home/ubuntu/otg-examples/public-cloud/azure/community-mellanox/deployment/Docker/Makefile /home/ubuntu/.

# Execute the tests
ssh -i SshKey.pem ubuntu@$IP make run
