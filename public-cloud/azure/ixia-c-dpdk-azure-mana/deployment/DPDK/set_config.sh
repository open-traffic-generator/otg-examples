#!/bin/bash

config_files_path=/home/ubuntu/otg-examples/snappi/data-plane-performance/configs/
settings_path=/home/ubuntu/otg-examples/snappi/data-plane-performance/

# get MACs
Agent1Eth1MacAddress=$(cat .agent1 | grep "AgentEth1MacAddress" | cut -d '=' -f 2)
Agent1Eth2MacAddress=$(cat .agent1 | grep "AgentEth2MacAddress" | cut -d '=' -f 2)
Agent1Eth3MacAddress=$(cat .agent1 | grep "AgentEth3MacAddress" | cut -d '=' -f 2)
Agent1Eth4MacAddress=$(cat .agent1 | grep "AgentEth4MacAddress" | cut -d '=' -f 2)
Agent1Eth5MacAddress=$(cat .agent1 | grep "AgentEth5MacAddress" | cut -d '=' -f 2)
Agent1Eth6MacAddress=$(cat .agent1 | grep "AgentEth6MacAddress" | cut -d '=' -f 2)
Agent1Eth7MacAddress=$(cat .agent1 | grep "AgentEth7MacAddress" | cut -d '=' -f 2)

Agent2Eth1MacAddress=$(cat .agent2 | grep "AgentEth1MacAddress" | cut -d '=' -f 2)
Agent2Eth2MacAddress=$(cat .agent2 | grep "AgentEth2MacAddress" | cut -d '=' -f 2)
Agent2Eth3MacAddress=$(cat .agent2 | grep "AgentEth3MacAddress" | cut -d '=' -f 2)
Agent2Eth4MacAddress=$(cat .agent2 | grep "AgentEth4MacAddress" | cut -d '=' -f 2)
Agent2Eth5MacAddress=$(cat .agent2 | grep "AgentEth5MacAddress" | cut -d '=' -f 2)
Agent2Eth6MacAddress=$(cat .agent2 | grep "AgentEth6MacAddress" | cut -d '=' -f 2)
Agent2Eth7MacAddress=$(cat .agent2 | grep "AgentEth7MacAddress" | cut -d '=' -f 2)

# get IPs
Agent1Eth0IpAddress=$(cat .agent1 | grep "AgentEth0IpAddress" | cut -d '=' -f 2)
Agent1Eth1IpAddress=$(cat .agent1 | grep "AgentEth1IpAddress" | cut -d '=' -f 2)
Agent1Eth2IpAddress=$(cat .agent1 | grep "AgentEth2IpAddress" | cut -d '=' -f 2)
Agent1Eth3IpAddress=$(cat .agent1 | grep "AgentEth3IpAddress" | cut -d '=' -f 2)
Agent1Eth4IpAddress=$(cat .agent1 | grep "AgentEth4IpAddress" | cut -d '=' -f 2)
Agent1Eth5IpAddress=$(cat .agent1 | grep "AgentEth5IpAddress" | cut -d '=' -f 2)
Agent1Eth6IpAddress=$(cat .agent1 | grep "AgentEth6IpAddress" | cut -d '=' -f 2)
Agent1Eth7IpAddress=$(cat .agent1 | grep "AgentEth7IpAddress" | cut -d '=' -f 2)

Agent2Eth0IpAddress=$(cat .agent2 | grep "AgentEth0IpAddress" | cut -d '=' -f 2)
Agent2Eth1IpAddress=$(cat .agent2 | grep "AgentEth1IpAddress" | cut -d '=' -f 2)
Agent2Eth2IpAddress=$(cat .agent2 | grep "AgentEth2IpAddress" | cut -d '=' -f 2)
Agent2Eth3IpAddress=$(cat .agent2 | grep "AgentEth3IpAddress" | cut -d '=' -f 2)
Agent2Eth4IpAddress=$(cat .agent2 | grep "AgentEth4IpAddress" | cut -d '=' -f 2)
Agent2Eth5IpAddress=$(cat .agent2 | grep "AgentEth5IpAddress" | cut -d '=' -f 2)
Agent2Eth6IpAddress=$(cat .agent2 | grep "AgentEth6IpAddress" | cut -d '=' -f 2)
Agent2Eth7IpAddress=$(cat .agent2 | grep "AgentEth7IpAddress" | cut -d '=' -f 2)


# Replace placeholder values from config files
# Agent1 MAC addresses
sed -i "s/Agent1Eth1MacAddress/$Agent1Eth1MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth2MacAddress/$Agent1Eth2MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth3MacAddress/$Agent1Eth3MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth4MacAddress/$Agent1Eth4MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth5MacAddress/$Agent1Eth5MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth6MacAddress/$Agent1Eth6MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth7MacAddress/$Agent1Eth7MacAddress/g" ${config_files_path}/*.json

# Agent2 MAC addresses
sed -i "s/Agent2Eth1MacAddress/$Agent2Eth1MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth2MacAddress/$Agent2Eth2MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth3MacAddress/$Agent2Eth3MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth4MacAddress/$Agent2Eth4MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth5MacAddress/$Agent2Eth5MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth6MacAddress/$Agent2Eth6MacAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth7MacAddress/$Agent2Eth7MacAddress/g" ${config_files_path}/*.json

# Agent1 IP addresses
sed -i "s/Agent1Eth0IpAddress/$Agent1Eth0IpAddress/g" ${settings_path}/*.json
sed -i "s/Agent1Eth1IpAddress/$Agent1Eth1IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth2IpAddress/$Agent1Eth2IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth3IpAddress/$Agent1Eth3IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth4IpAddress/$Agent1Eth4IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth5IpAddress/$Agent1Eth5IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth6IpAddress/$Agent1Eth6IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent1Eth7IpAddress/$Agent1Eth7IpAddress/g" ${config_files_path}/*.json

# Agent2 IP addresses
sed -i "s/Agent2Eth0IpAddress/$Agent2Eth0IpAddress/g" ${settings_path}/*.json
sed -i "s/Agent2Eth1IpAddress/$Agent2Eth1IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth2IpAddress/$Agent2Eth2IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth3IpAddress/$Agent2Eth3IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth4IpAddress/$Agent2Eth4IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth5IpAddress/$Agent2Eth5IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth6IpAddress/$Agent2Eth6IpAddress/g" ${config_files_path}/*.json
sed -i "s/Agent2Eth7IpAddress/$Agent2Eth7IpAddress/g" ${config_files_path}/*.json
