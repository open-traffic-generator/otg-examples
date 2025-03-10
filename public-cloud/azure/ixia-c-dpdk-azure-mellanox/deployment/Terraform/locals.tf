locals {
	AgentUserName = "ubuntu"
	AgentVmSize = var.AgentVmSize
	Agent1InstanceId = "agent1"
	Agent1Eth1IpAddresses = [ "10.0.2.11" ]
	Agent2Eth0IpAddress = "10.0.10.12"
	Agent2Eth1IpAddresses = [ "10.0.2.21" ]
	Agent2InstanceId = "agent2"
	AppTag = "azure"
	AppVersion = "mellanox"
	GitRepoBasePath = "/home/${local.AgentUserName}/${local.GitRepoName}"
	GitRepoDeployPath = "${local.GitRepoBasePath}/public-cloud/${local.AppTag}/ixia-c-dpdk-${local.AppTag}-${local.AppVersion}/deployment"
	GitRepoName = "otg-examples"
	GitRepoUrl = "-b cloud https://github.com/open-traffic-generator/otg-examples.git"
	Preamble = "${local.UserLoginTag}-${local.UserProjectTag}-${local.AppTag}"
	PublicSecurityRuleSourceIpPrefixes = var.PublicSecurityRuleSourceIpPrefixes == null ? [ "${data.http.ip.response_body}/32" ] : var.PublicSecurityRuleSourceIpPrefixes
	ResourceGroupLocation = var.ResourceGroupLocation
	ResourceGroupName = var.ResourceGroupName == null ? "${local.Preamble}-resource-group" : var.ResourceGroupName
	SleepDelay = "5m"
	SshKeyAlgorithm = "RSA"
	SshKeyName = "${local.Preamble}-ssh-key"
	SshKeyRsaBits = "4096"
	SubscriptionId = var.SubscriptionId
	UserEmailTag = var.UserEmailTag == null ? data.azurerm_client_config.current.client_id : var.UserEmailTag
	UserLoginTag = var.UserLoginTag == null ? "terraform" : var.UserLoginTag
	UserProjectTag = var.UserProjectTag == null ? random_id.RandomId.id : var.UserProjectTag
}