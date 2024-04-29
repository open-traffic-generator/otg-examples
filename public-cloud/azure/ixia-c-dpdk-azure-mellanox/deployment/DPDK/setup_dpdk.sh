#!/bin/bash
UserName="ubuntu"
GitRepoBasePath="/home/$UserName/keng-python"
GitRepoExecPath="$GitRepoBasePath/snappi/data-plane-performance"
# GitRepoDeployPath="$GitRepoExecPath/deployment"
GitRepoDeployPath="$GitRepoBasePath/public-cloud/azure/ixia-c-dpdk-azure-mellanox/configs"
AgentBusInfoList=$(lshw -C network -json | jq '.[] | select( .businfo != null)' | jq -r .businfo)
AgentEth1BusInfo=$(echo $AgentBusInfoList | awk '{print $1}')
AgentEth2BusInfo=$(echo $AgentBusInfoList | awk '{print $2}')
AgentEth3BusInfo=$(echo $AgentBusInfoList | awk '{print $3}')
AgentEth4BusInfo=$(echo $AgentBusInfoList | awk '{print $4}')
AgentEth5BusInfo=$(echo $AgentBusInfoList | awk '{print $5}')
AgentEth6BusInfo=$(echo $AgentBusInfoList | awk '{print $6}')
AgentEth7BusInfo=$(echo $AgentBusInfoList | awk '{print $7}')
echo "AgentEth1BusInfo=$AgentEth1BusInfo" > $GitRepoDeployPath/.env
echo "AgentEth2BusInfo=$AgentEth2BusInfo" >> $GitRepoDeployPath/.env
echo "AgentEth3BusInfo=$AgentEth3BusInfo" >> $GitRepoDeployPath/.env
echo "AgentEth4BusInfo=$AgentEth4BusInfo" >> $GitRepoDeployPath/.env
echo "AgentEth5BusInfo=$AgentEth5BusInfo" >> $GitRepoDeployPath/.env
echo "AgentEth6BusInfo=$AgentEth6BusInfo" >> $GitRepoDeployPath/.env
echo "AgentEth7BusInfo=$AgentEth7BusInfo" >> $GitRepoDeployPath/.env
chmod +x $GitRepoDeployPath/setup.sh
$GitRepoDeployPath/setup.sh