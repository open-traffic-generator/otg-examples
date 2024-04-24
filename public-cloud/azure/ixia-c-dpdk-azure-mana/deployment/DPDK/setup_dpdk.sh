#!/bin/bash
UserName="ubuntu"
GitRepoBasePath="/home/$UserName/keng-python"
GitRepoExecPath="$GitRepoBasePath/snappi/data-plane-performance"
GitRepoDeployPath="$GitRepoExecPath/deployment"
AgentEth1BusInfo=$(lshw -C network -json | jq .[1].businfo --raw-output)
echo "AgentEth1BusInfo=$AgentEth1BusInfo" > $GitRepoDeployPath/.env
chmod +x $GitRepoDeployPath/setup.sh
$GitRepoDeployPath/setup.sh