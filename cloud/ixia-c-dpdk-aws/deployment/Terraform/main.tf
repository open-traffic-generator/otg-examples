module "Agent1" {
	source = "armdupre/module-ubuntu-linux-agent/aws"
	version = "0.1.1"
	Eth0SecurityGroupId = module.Vpc.PublicSecurityGroup.id
	Eth0SubnetId = module.Vpc.PublicSubnet.id
	Eth1PrivateIpAddresses = local.Agent1Eth1PrivateIpAddresses
	Eth1SecurityGroupId = module.Vpc.PrivateSecurityGroup.id
	Eth1SubnetId = module.Vpc.PrivateSubnet.id
	InstanceId = local.Agent1InstanceId
	InstanceType = local.AgentInstanceType
	PlacementGroupId = aws_placement_group.PlacementGroup.id
	SleepDelay = local.SleepDelay
	UserEmailTag = local.UserEmailTag
	UserLoginTag = local.UserLoginTag
	UserProjectTag = local.UserProjectTag
	Version = local.AppVersion
	init_cli = data.cloudinit_config.init_cli.rendered
	depends_on = [
		aws_key_pair.SshKey,
		aws_placement_group.PlacementGroup,
		module.Vpc
	]
}

module "Agent2" {
	source = "armdupre/module-ubuntu-linux-agent/aws"
	version = "0.1.1"
	Eth0PrivateIpAddress = local.Agent2Eth0PrivateIpAddress
	Eth0SecurityGroupId = module.Vpc.PublicSecurityGroup.id
	Eth0SubnetId = module.Vpc.PublicSubnet.id
	Eth1PrivateIpAddresses = local.Agent2Eth1PrivateIpAddresses
	Eth1SecurityGroupId = module.Vpc.PrivateSecurityGroup.id
	Eth1SubnetId = module.Vpc.PrivateSubnet.id
	InstanceId = local.Agent2InstanceId
	InstanceType = local.AgentInstanceType
	PlacementGroupId = aws_placement_group.PlacementGroup.id
	SleepDelay = local.SleepDelay
	UserEmailTag = local.UserEmailTag
	UserLoginTag = local.UserLoginTag
	UserProjectTag = local.UserProjectTag
	Version = local.AppVersion
	init_cli = data.cloudinit_config.init_cli.rendered
	depends_on = [
		aws_key_pair.SshKey,
		aws_placement_group.PlacementGroup,
		module.Vpc
	]
}

resource "aws_placement_group" "PlacementGroup" {
	name = local.PlacementGroupName
	strategy = local.PlacementGroupStrategy
}