#!/bin/bash
UserName="ubuntu"
GitRepoBasePath="/home/$UserName/keng-python"
GitRepoExecPath="$GitRepoBasePath/snappi/data-plane-performance"
# GitRepoDeployPath="$GitRepoExecPath/deployment"
GitRepoDeployPath="$GitRepoBasePath/public-cloud/azure/ixia-c-dpdk-azure-mana/configs"
AgentEth1MacAddress=$(cat /sys/class/net/eth1/address)
AgentEth2MacAddress=$(cat /sys/class/net/eth2/address)
AgentEth3MacAddress=$(cat /sys/class/net/eth3/address)
AgentEth4MacAddress=$(cat /sys/class/net/eth4/address)
AgentEth5MacAddress=$(cat /sys/class/net/eth5/address)
AgentEth6MacAddress=$(cat /sys/class/net/eth6/address)
AgentEth7MacAddress=$(cat /sys/class/net/eth7/address)
echo "AgentEth1MacAddress=$AgentEth1MacAddress" > $GitRepoDeployPath/.env
echo "AgentEth2MacAddress=$AgentEth2MacAddress" > $GitRepoDeployPath/.env
echo "AgentEth3MacAddress=$AgentEth3MacAddress" > $GitRepoDeployPath/.env
echo "AgentEth4MacAddress=$AgentEth4MacAddress" > $GitRepoDeployPath/.env
echo "AgentEth5MacAddress=$AgentEth5MacAddress" > $GitRepoDeployPath/.env
echo "AgentEth6MacAddress=$AgentEth6MacAddress" > $GitRepoDeployPath/.env
echo "AgentEth7MacAddress=$AgentEth7MacAddress" > $GitRepoDeployPath/.env
AgentBusInfoList=$(lshw -C network -json | jq '.[] | select( .businfo != null)' | jq -r .businfo)
AgentEth1BusInfo=$(echo $AgentBusInfoList | awk '{print $1}')
AgentEth2BusInfo=$(echo $AgentBusInfoList | awk '{print $2}')
AgentEth3BusInfo=$(echo $AgentBusInfoList | awk '{print $3}')
AgentEth4BusInfo=$(echo $AgentBusInfoList | awk '{print $4}')
AgentEth5BusInfo=$(echo $AgentBusInfoList | awk '{print $5}')
AgentEth6BusInfo=$(echo $AgentBusInfoList | awk '{print $6}')
AgentEth7BusInfo=$(echo $AgentBusInfoList | awk '{print $7}')
echo "AgentEth1BusInfo=$AgentEth1BusInfo" > $GitRepoDeployPath/.env
echo "AgentEth2BusInfo=$AgentEth2BusInfo" > $GitRepoDeployPath/.env
echo "AgentEth3BusInfo=$AgentEth3BusInfo" > $GitRepoDeployPath/.env
echo "AgentEth4BusInfo=$AgentEth4BusInfo" > $GitRepoDeployPath/.env
echo "AgentEth5BusInfo=$AgentEth5BusInfo" > $GitRepoDeployPath/.env
echo "AgentEth6BusInfo=$AgentEth6BusInfo" > $GitRepoDeployPath/.env
echo "AgentEth7BusInfo=$AgentEth7BusInfo" > $GitRepoDeployPath/.env
AgentEth1VmBus=$(readlink /sys/class/net/eth1/device | xargs basename)
AgentEth2VmBus=$(readlink /sys/class/net/eth2/device | xargs basename)
AgentEth3VmBus=$(readlink /sys/class/net/eth3/device | xargs basename)
AgentEth4VmBus=$(readlink /sys/class/net/eth4/device | xargs basename)
AgentEth5VmBus=$(readlink /sys/class/net/eth5/device | xargs basename)
AgentEth6VmBus=$(readlink /sys/class/net/eth6/device | xargs basename)
AgentEth7VmBus=$(readlink /sys/class/net/eth7/device | xargs basename)
echo "AgentEth1VmBus=$AgentEth1VmBus" > $GitRepoDeployPath/.env
echo "AgentEth2VmBus=$AgentEth2VmBus" > $GitRepoDeployPath/.env
echo "AgentEth3VmBus=$AgentEth3VmBus" > $GitRepoDeployPath/.env
echo "AgentEth4VmBus=$AgentEth4VmBus" > $GitRepoDeployPath/.env
echo "AgentEth5VmBus=$AgentEth5VmBus" > $GitRepoDeployPath/.env
echo "AgentEth6VmBus=$AgentEth6VmBus" > $GitRepoDeployPath/.env
echo "AgentEth7VmBus=$AgentEth7VmBus" > $GitRepoDeployPath/.env
modprobe mana_ib
chmod +x $GitRepoDeployPath/setup.sh
$GitRepoDeployPath/setup.sh