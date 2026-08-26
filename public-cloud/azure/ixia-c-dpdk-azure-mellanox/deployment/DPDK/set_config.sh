#!/bin/bash

config_files_path=/home/ubuntu/otg-examples/public-cloud/azure/ixia-c-dpdk-azure-mellanox/configs/

Agent1_file=/home/ubuntu/otg-examples/public-cloud/azure/ixia-c-dpdk-azure-mellanox/deployment/DPDK/.agent1
Agent2_file=/home/ubuntu/otg-examples/public-cloud/azure/ixia-c-dpdk-azure-mellanox/deployment/DPDK/.agent2

# get MACs
Agent1Eth1MacAddress=$(cat $Agent1_file | grep "AgentEth1MacAddress" | cut -d '=' -f 2)
Agent2Eth1MacAddress=$(cat $Agent2_file | grep "AgentEth1MacAddress" | cut -d '=' -f 2)

# get IPs
Agent1Eth0IpAddress=$(cat $Agent1_file | grep "AgentEth0IpAddress" | cut -d '=' -f 2)
Agent1Eth1IpAddress=$(cat $Agent1_file | grep "AgentEth1IpAddress" | cut -d '=' -f 2)

Agent2Eth0IpAddress=$(cat $Agent2_file | grep "AgentEth0IpAddress" | cut -d '=' -f 2)
Agent2Eth1IpAddress=$(cat $Agent2_file | grep "AgentEth1IpAddress" | cut -d '=' -f 2)


# Replace placeholder values from config files
# Agent1 MAC addresses
sed -i "s/Agent1Eth1MacAddress/$Agent1Eth1MacAddress/g" ${config_files_path}/*.json

# Agent2 MAC addresses
sed -i "s/Agent2Eth1MacAddress/$Agent2Eth1MacAddress/g" ${config_files_path}/*.json

# Agent1 IP addresses
sed -i "s/Agent1Eth0IpAddress/$Agent1Eth0IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth1IpAddress/$Agent1Eth1IpAddress/g" ${config_files_path}/*.json

# Agent2 IP addresses
sed -i "s/Agent2Eth0IpAddress/$Agent2Eth0IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth1IpAddress/$Agent2Eth1IpAddress/g" ${config_files_path}/*.json


cp ${config_files_path}/unidirectional.json /home/ubuntu/otg-examples/snappi/data-plane-performance/configs/.
cp ${config_files_path}/bidirectional.json /home/ubuntu/otg-examples/snappi/data-plane-performance/configs/.
cp ${config_files_path}/settings.json /home/ubuntu/otg-examples/snappi/data-plane-performance/.