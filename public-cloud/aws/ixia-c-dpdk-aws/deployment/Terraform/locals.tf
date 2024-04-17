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
	GitRepoBasePath = "public-cloud/aws/ixia-c-dpdk-aws"
	GitRepoConfigPath = "${local.GitRepoExecPath}/configs"
	GitRepoDeployPath = "${local.GitRepoBasePath}/deployment"
	GitRepoExecPath = "${local.GitRepoBasePath}/application"
	GitRepoName = var.GitRepoName
	GitRepoUrl = var.GitRepoUrl
	InboundIPv4CidrBlocks = [ "${data.http.ip.response_body}/32" ]
	PlacementGroupName = "${local.Preamble}-placement-group-${local.Region}"
	PlacementGroupStrategy = "cluster"
	Preamble = "${local.UserLoginTag}-${local.UserProjectTag}-${local.AppTag}-${local.AppVersion}"
	PrivateSubnetAvailabilityZone = var.PrivateSubnetAvailabilityZone
	PublicSubnetAvailabilityZone = var.PublicSubnetAvailabilityZone
	Region = data.aws_region.current.name
	SleepDelay = "5m"
	UserLoginTag = "terraform"
	UserEmailTag = data.aws_caller_identity.current.user_id
	UserProjectTag = random_id.RandomId.id
}