#!/bin/bash

while getopts i: flag
do
    case "${flag}" in
        i) PublicIp=${OPTARG};;
    esac
done

aws ec2 describe-instances \
	--filters "Name=instance-state-name,Values=running" "Name=network-interface.association.public-ip,Values=$PublicIp" \
	--query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name'].Value|[0]]" \
	--output table
AgentId=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=network-interface.association.public-ip,Values=$PublicIp" --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name'].Value|[0]]" --output json | jq .[0][0] --raw-output)
aws ssm start-session \
	--target $AgentId