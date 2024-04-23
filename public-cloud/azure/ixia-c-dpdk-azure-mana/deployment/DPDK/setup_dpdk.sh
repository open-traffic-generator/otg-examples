#!/bin/bash
UserName="ubuntu"
GitRepoName="keng-python"
GitRepoBasePath="/home/$UserName/$GitRepoName/public-cloud/azure/ixia-c-dpdk-azure-mana"
GitRepoExecPath="$GitRepoBasePath/application"
GitRepoDeployPath="$GitRepoExecPath/deployment"
AgentEth1LogicalName=$(lshw -C network -json | jq .[1].logicalname --raw-output)
AgentEth1BusInfo=$(lshw -C network -json | jq .[1].businfo --raw-output)
echo "AgentEth1BusInfo=$AgentEth1BusInfo" > $GitRepoDeployPath/.env
chmod +x $GitRepoDeployPath/setup.sh
$GitRepoDeployPath/setup.sh