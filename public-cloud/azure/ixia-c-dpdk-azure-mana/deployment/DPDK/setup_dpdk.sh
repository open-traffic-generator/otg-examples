#!/bin/bash
UserName="ubuntu"
GitRepoName="keng-python"
GitRepoBasePath="/home/$UserName/$GitRepoName/public-cloud/aws/ixia-c-dpdk-aws"
GitRepoExecPath="$GitRepoBasePath/application"
GitRepoDeployPath="$GitRepoExecPath/deployment"
AgentEth1LogicalName=$(lshw -C network -json | jq .[1].logicalname --raw-output)
AgentEth1BusInfo=$(lshw -C network -json | jq .[1].businfo --raw-output)
echo "AgentEth1BusInfo=$AgentEth1BusInfo" > $GitRepoDeployPath/.env
modprobe uio
modprobe igb_uio
sudo -H -u $UserName bash -c 'git clone https://github.com/DPDK/dpdk.git $HOME/dpdk'
/home/$UserName/dpdk/usertools/dpdk-devbind.py -b igb_uio $AgentEth1LogicalName -s --force
chmod +x $GitRepoDeployPath/setup.sh
$GitRepoDeployPath/setup.sh