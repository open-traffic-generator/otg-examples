locals {
	AgentUserName = "ubuntu"
	AgentVmSize = "Standard_F8s_v2"
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
	Preamble = "${local.UserLoginTag}-${local.AppTag}-${local.AppVersion}"
	PublicSecurityRuleSourceIpPrefixes = [ "${data.http.ip.response_body}/32" ]
	ResourceGroupLocation = var.ResourceGroupLocation
	ResourceGroupName = "${local.UserLoginTag}-${local.UserProjectTag}-ixia-c-dpdk-${local.AppTag}-${local.AppVersion}"
	SleepDelay = "5m"
	SshKeyAlgorithm = "RSA"
	SshKeyName = "${local.Preamble}-ssh-key"
	SshKeyRsaBits = "4096"
	UserEmailTag = "terraform@example.com"
	UserLoginTag = "terraform"
	UserProjectTag = random_id.RandomId.id
}
