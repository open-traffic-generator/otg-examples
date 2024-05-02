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
Eth2_mac=$(echo $NetworkHardwareList | jq '.[] | select(.logicalname == "eth2")' | jq -r '.serial')
Eth3_mac=$(echo $NetworkHardwareList | jq '.[] | select(.logicalname == "eth3")' | jq -r '.serial')
Eth4_mac=$(echo $NetworkHardwareList | jq '.[] | select(.logicalname == "eth4")' | jq -r '.serial')
Eth5_mac=$(echo $NetworkHardwareList | jq '.[] | select(.logicalname == "eth5")' | jq -r '.serial')
Eth6_mac=$(echo $NetworkHardwareList | jq '.[] | select(.logicalname == "eth6")' | jq -r '.serial')
Eth7_mac=$(echo $NetworkHardwareList | jq '.[] | select(.logicalname == "eth7")' | jq -r '.serial')

# Get the bus infos adresses for eth1, eth2, ..., eth7
AgentEth1BusInfo=$(echo $NetworkHardwareList | jq ".[] | select(.serial == \"$Eth1_mac\" and .businfo != null)" | jq -r .businfo)
AgentEth2BusInfo=$(echo $NetworkHardwareList | jq ".[] | select(.serial == \"$Eth2_mac\" and .businfo != null)" | jq -r .businfo)
AgentEth3BusInfo=$(echo $NetworkHardwareList | jq ".[] | select(.serial == \"$Eth3_mac\" and .businfo != null)" | jq -r .businfo)
AgentEth4BusInfo=$(echo $NetworkHardwareList | jq ".[] | select(.serial == \"$Eth4_mac\" and .businfo != null)" | jq -r .businfo)
AgentEth5BusInfo=$(echo $NetworkHardwareList | jq ".[] | select(.serial == \"$Eth5_mac\" and .businfo != null)" | jq -r .businfo)
AgentEth6BusInfo=$(echo $NetworkHardwareList | jq ".[] | select(.serial == \"$Eth6_mac\" and .businfo != null)" | jq -r .businfo)
AgentEth7BusInfo=$(echo $NetworkHardwareList | jq ".[] | select(.serial == \"$Eth7_mac\" and .businfo != null)" | jq -r .businfo)

# Set docker-compose variables
echo "AgentEth1BusInfo=$AgentEth1BusInfo" > $GitRepoDeployPath/.env
echo "AgentEth2BusInfo=$AgentEth2BusInfo" >> $GitRepoDeployPath/.env
echo "AgentEth3BusInfo=$AgentEth3BusInfo" >> $GitRepoDeployPath/.env
echo "AgentEth4BusInfo=$AgentEth4BusInfo" >> $GitRepoDeployPath/.env
echo "AgentEth5BusInfo=$AgentEth5BusInfo" >> $GitRepoDeployPath/.env
echo "AgentEth6BusInfo=$AgentEth6BusInfo" >> $GitRepoDeployPath/.env
echo "AgentEth7BusInfo=$AgentEth7BusInfo" >> $GitRepoDeployPath/.env
chmod +x $GitRepoDeployPath/setup.sh

# Run setup.sh (allocates hugepages)
$GitRepoDeployPath/setup.sh
