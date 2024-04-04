locals {
	AgentInstanceType = var.AgentInstanceType
	Agent1InstanceId = "agent1"
	Agent1Eth1PrivateIpAddresses = [ "10.0.2.12", "10.0.2.13" ]
	Agent2Eth0PrivateIpAddress = "10.0.10.12"
	Agent2Eth1PrivateIpAddresses = [ "10.0.2.22", "10.0.2.23" ]
	Agent2InstanceId = "agent2"
	AppTag = "ubuntu"
	AppVersion = "2204-lts"
	AwsMetadataServerUrl = var.AwsMetadataServerUrl
	GitRepoConfigPath = "${local.GitRepoExecPath}/configs"
	GitRepoExecPath = "cloud/ixia-c-dpdk-aws"
	GitRepoName = var.GitRepoName
	GitRepoUrl = var.GitRepoUrl
	InboundIPv4CidrBlocks = var.InboundIPv4CidrBlocks
	PlacementGroupName = "${local.Preamble}-placement-group-${local.Region}"
	PlacementGroupStrategy = "cluster"
	Preamble = "${local.UserLoginTag}-${local.UserProjectTag}-${local.AppTag}-${local.AppVersion}"
	PrivateSubnetAvailabilityZone = var.PrivateSubnetAvailabilityZone
	PublicSubnetAvailabilityZone = var.PublicSubnetAvailabilityZone
	Region = data.aws_region.current.name
	SshKeyAlgorithm = "RSA"
	SshKeyName = "${local.Preamble}-ssh-key"
	SshKeyRsaBits = "4096"
	UserEmailTag = var.UserEmailTag
	UserLoginTag = var.UserLoginTag
	UserProjectTag = var.UserProjectTag
}