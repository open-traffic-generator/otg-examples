#!/bin/bash
UserName="ubuntu"
GitRepoBasePath="/home/$UserName/otg-examples"
GitRepoExecPath="$GitRepoBasePath/snappi/data-plane-performance"
# GitRepoDeployPath="$GitRepoExecPath/deployment"
GitRepoDeployPath="$GitRepoBasePath/public-cloud/azure/ixia-c-dpdk-azure-mellanox/configs"
# Get the list of all network interfaces
NetworkHardwareList=$(lshw -C network -json)

# Get the mac adresses for eth1, eth2, ..., eth7
Eth1_mac=$(echo $NetworkHardwareList | jq '.[] | select(.logicalname == "eth1")' | jq -r '.serial')

# Get the ip adresses for eth0, eth1, eth2, ..., eth7
Eth0_ip=$(lshw -C network -json | jq '.[] | select(.logicalname == "eth0")' | jq -r '.configuration.ip')
Eth1_ip=$(lshw -C network -json | jq '.[] | select(.logicalname == "eth1")' | jq -r '.configuration.ip')

# Get the bus infos adresses for eth1, eth2, ..., eth7
AgentEth1BusInfo=$(echo $NetworkHardwareList | jq ".[] | select(.serial == \"$Eth1_mac\" and .businfo != null)" | jq -r .businfo)

# Set docker-compose variables
echo "AgentEth1BusInfo=$AgentEth1BusInfo" > $GitRepoDeployPath/.env

# Set mac addresses
echo "AgentEth1MacAddress=$Eth1_mac" >> $GitRepoDeployPath/.env

#Set ip addresses
echo "AgentEth0IpAddress=$Eth0_ip" >> $GitRepoDeployPath/.env
echo "AgentEth1IpAddress=$Eth1_ip" >> $GitRepoDeployPath/.env

chmod +x $GitRepoDeployPath/setup.sh

# Run setup.sh (allocates hugepages)
$GitRepoDeployPath/setup.sh