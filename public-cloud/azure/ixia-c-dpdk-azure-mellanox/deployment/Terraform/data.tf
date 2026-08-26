data "azurerm_client_config" "current" { }

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
			GitRepoDeployPath: local.GitRepoDeployPath
		})
	}	
}

data "http" "ip" {
	url = "https://ifconfig.me"
}