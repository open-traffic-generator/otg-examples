data "azurerm_subscription" "current" {}

data "azurerm_subscriptions" "available" {}

data "cloudinit_config" "init_cli" {
	gzip = false
	base64_encode = false
	part {
		content_type = "text/cloud-config"
		content = templatefile("cloud-init.yml", {
			GitRepoDeployPath: local.GitRepoDeployPath
			GitRepoName: local.GitRepoName
			GitRepoUrl: local.GitRepoUrl
			UserName: local.AgentUserName
		})
	}
	part {
		filename = "script-001"
		content_type = "text/cloud-config"
		content = templatefile("cloud-init.azure.yml", {
			Agent1Eth1PrivateIpAddresses: local.Agent1Eth1IpAddresses
			Agent1Eth2PrivateIpAddresses: local.Agent1Eth2IpAddresses
			Agent2Eth0IpAddress: local.Agent2Eth0IpAddress
			Agent2Eth1PrivateIpAddresses: local.Agent2Eth1IpAddresses
			Agent2Eth2PrivateIpAddresses: local.Agent2Eth2IpAddresses
			GitRepoConfigPath: local.GitRepoConfigPath
			GitRepoDeployPath: local.GitRepoDeployPath
			GitRepoExecDeployPath: local.GitRepoExecDeployPath
			GitRepoName: local.GitRepoName
			ResourceGroupName: local.ResourceGroupName
			UserName: local.AgentUserName
		})
	}	
}

data "http" "ip" {
	url = "https://ifconfig.me"
}