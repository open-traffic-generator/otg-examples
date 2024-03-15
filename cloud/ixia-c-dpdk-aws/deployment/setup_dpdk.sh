#!/bin/bash
UserName="ubuntu"
GitRepoName="keng-python"
GitDeployPath="cloud/ixia-c-dpdk-aws/deployment"
AgentEth1LogicalName=$(lshw -C network -json | jq .[1].logicalname --raw-output)
AgentEth1BusInfo=$(lshw -C network -json | jq .[1].businfo --raw-output)
echo "AgentEth1BusInfo=$AgentEth1BusInfo" > /home/$UserName/$GitRepoName/$GitRepoDeployPath/.env
modprobe uio
modprobe igb_uio
sudo -H -u $UserName bash -c 'git clone https://github.com/DPDK/dpdk.git $HOME/dpdk'
/home/$UserName/dpdk/usertools/dpdk-devbind.py -b igb_uio $AgentEth1LogicalName -s --force
chmod +x /home/$UserName/$GitRepoName/$GitRepoDeployPath/setup.sh
/home/$UserName/$GitRepoName/$GitRepoDeployPath/setup.sh