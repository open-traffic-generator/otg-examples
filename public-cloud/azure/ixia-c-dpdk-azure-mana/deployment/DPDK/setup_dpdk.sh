#!/bin/bash
UserName="ubuntu"
GitRepoBasePath="/home/$UserName/otg-examples"
GitRepoExecPath="$GitRepoBasePath/snappi/data-plane-performance"
# GitRepoDeployPath="$GitRepoExecPath/deployment"
GitRepoDeployPath="$GitRepoBasePath/public-cloud/azure/ixia-c-dpdk-azure-mana/configs"
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

# Get the ip adresses for eth0, eth1, eth2, ..., eth7
Eth0_ip=$(lshw -C network -json | jq '.[] | select(.logicalname == "eth0")' | jq -r '.configuration.ip')
Eth1_ip=$(lshw -C network -json | jq '.[] | select(.logicalname == "eth1")' | jq -r '.configuration.ip')
Eth2_ip=$(lshw -C network -json | jq '.[] | select(.logicalname == "eth2")' | jq -r '.configuration.ip')
Eth3_ip=$(lshw -C network -json | jq '.[] | select(.logicalname == "eth3")' | jq -r '.configuration.ip')
Eth4_ip=$(lshw -C network -json | jq '.[] | select(.logicalname == "eth4")' | jq -r '.configuration.ip')
Eth5_ip=$(lshw -C network -json | jq '.[] | select(.logicalname == "eth5")' | jq -r '.configuration.ip')
Eth6_ip=$(lshw -C network -json | jq '.[] | select(.logicalname == "eth6")' | jq -r '.configuration.ip')
Eth7_ip=$(lshw -C network -json | jq '.[] | select(.logicalname == "eth7")' | jq -r '.configuration.ip')

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

# Set mac addresses
echo "AgentEth1MacAddress=$Eth1_mac" >> $GitRepoDeployPath/.env
echo "AgentEth2MacAddress=$Eth2_mac" >> $GitRepoDeployPath/.env
echo "AgentEth3MacAddress=$Eth3_mac" >> $GitRepoDeployPath/.env
echo "AgentEth4MacAddress=$Eth4_mac" >> $GitRepoDeployPath/.env
echo "AgentEth5MacAddress=$Eth5_mac" >> $GitRepoDeployPath/.env
echo "AgentEth6MacAddress=$Eth6_mac" >> $GitRepoDeployPath/.env
echo "AgentEth7MacAddress=$Eth7_mac" >> $GitRepoDeployPath/.env

#Set ip addresses
echo "AgentEth0IpAddress=$Eth0_ip" >> $GitRepoDeployPath/.env
echo "AgentEth1IpAddress=$Eth1_ip" >> $GitRepoDeployPath/.env
echo "AgentEth2IpAddress=$Eth2_ip" >> $GitRepoDeployPath/.env
echo "AgentEth3IpAddress=$Eth3_ip" >> $GitRepoDeployPath/.env
echo "AgentEth4IpAddress=$Eth4_ip" >> $GitRepoDeployPath/.env
echo "AgentEth5IpAddress=$Eth5_ip" >> $GitRepoDeployPath/.env
echo "AgentEth6IpAddress=$Eth6_ip" >> $GitRepoDeployPath/.env
echo "AgentEth7IpAddress=$Eth7_ip" >> $GitRepoDeployPath/.env

# Set vmbus addresses
AgentEth1VmBus=$(readlink /sys/class/net/eth1/device | xargs basename)
AgentEth2VmBus=$(readlink /sys/class/net/eth2/device | xargs basename)
AgentEth3VmBus=$(readlink /sys/class/net/eth3/device | xargs basename)
AgentEth4VmBus=$(readlink /sys/class/net/eth4/device | xargs basename)
AgentEth5VmBus=$(readlink /sys/class/net/eth5/device | xargs basename)
AgentEth6VmBus=$(readlink /sys/class/net/eth6/device | xargs basename)
AgentEth7VmBus=$(readlink /sys/class/net/eth7/device | xargs basename)
echo "AgentEth1VmBus=$AgentEth1VmBus" >> $GitRepoDeployPath/.env
echo "AgentEth2VmBus=$AgentEth2VmBus" >> $GitRepoDeployPath/.env
echo "AgentEth3VmBus=$AgentEth3VmBus" >> $GitRepoDeployPath/.env
echo "AgentEth4VmBus=$AgentEth4VmBus" >> $GitRepoDeployPath/.env
echo "AgentEth5VmBus=$AgentEth5VmBus" >> $GitRepoDeployPath/.env
echo "AgentEth6VmBus=$AgentEth6VmBus" >> $GitRepoDeployPath/.env
echo "AgentEth7VmBus=$AgentEth7VmBus" >> $GitRepoDeployPath/.env

modprobe mana_ib
chmod +x $GitRepoDeployPath/setup.sh
$GitRepoDeployPath/setup.sh
