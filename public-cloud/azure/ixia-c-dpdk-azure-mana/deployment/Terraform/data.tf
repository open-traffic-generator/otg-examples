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
			Agent1Eth2PrivateIpAddresses: local.Agent1Eth2IpAddresses
			Agent1Eth3PrivateIpAddresses: local.Agent1Eth3IpAddresses
			Agent1Eth4PrivateIpAddresses: local.Agent1Eth4IpAddresses
			Agent1Eth5PrivateIpAddresses: local.Agent1Eth5IpAddresses
			Agent1Eth6PrivateIpAddresses: local.Agent1Eth6IpAddresses
			Agent1Eth7PrivateIpAddresses: local.Agent1Eth7IpAddresses
			Agent2Eth0IpAddress: local.Agent2Eth0IpAddress
			Agent2Eth1PrivateIpAddresses: local.Agent2Eth1IpAddresses
			Agent2Eth2PrivateIpAddresses: local.Agent2Eth2IpAddresses
			Agent2Eth3PrivateIpAddresses: local.Agent2Eth3IpAddresses
			Agent2Eth4PrivateIpAddresses: local.Agent2Eth4IpAddresses
			Agent2Eth5PrivateIpAddresses: local.Agent2Eth5IpAddresses
			Agent2Eth6PrivateIpAddresses: local.Agent2Eth6IpAddresses
			Agent2Eth7PrivateIpAddresses: local.Agent2Eth7IpAddresses
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