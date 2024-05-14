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
			AgentUserName: local.AgentUserName
		})
	}
	part {
		filename = "script-001"
		content_type = "text/cloud-config"
		content = templatefile("cloud-init.azure.yml", {
			Agent1Eth1PrivateIpAddresses: local.Agent1Eth1IpAddresses
			Agent2Eth0IpAddress: local.Agent2Eth0IpAddress
			Agent2Eth1PrivateIpAddresses: local.Agent2Eth1IpAddresses
			GitRepoConfigPath: local.GitRepoConfigPath
			GitRepoDeployPath: local.GitRepoDeployPath
			GitRepoExecPath: local.GitRepoExecPath
			GitRepoExecDeployPath: local.GitRepoExecDeployPath
			ResourceGroupName: local.ResourceGroupName
		})
	}	
}

data "http" "ip" {
	url = "https://ifconfig.me"
}