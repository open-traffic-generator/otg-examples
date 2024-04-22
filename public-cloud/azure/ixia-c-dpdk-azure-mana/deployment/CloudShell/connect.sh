#!/bin/bash

while getopts i:k: flag
do
    case "${flag}" in
        i) PublicIp=${OPTARG};;
		k) SshKey=${OPTARG};;
    esac
done

chmod 400 $SshKey
ssh -i $SshKey ubuntu@$PublicIp