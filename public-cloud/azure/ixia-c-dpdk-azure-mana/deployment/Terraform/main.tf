module "Agent1" {
	source = "armdupre/module-keng-agent/azurerm"
	version = "0.1.0"
	Eth0SubnetId = module.Vnet.PublicSubnet.id
	Eth1IpAddresses = local.Agent1Eth1IpAddresses
	Eth1SubnetId = module.Vnet.PrivateSubnet.id
	Eth2IpAddresses = local.Agent1Eth2IpAddresses
	Eth2SubnetId = module.Vnet.PrivateSubnet.id
	Eth3IpAddresses = local.Agent1Eth3IpAddresses
	Eth3SubnetId = module.Vnet.PrivateSubnet.id
	Eth4IpAddresses = local.Agent1Eth4IpAddresses
	Eth4SubnetId = module.Vnet.PrivateSubnet.id
	InstanceId = local.Agent1InstanceId
	ResourceGroupLocation = azurerm_resource_group.ResourceGroup.location
	ResourceGroupName = azurerm_resource_group.ResourceGroup.name
	SleepDelay = local.SleepDelay
	SshKeyName = azurerm_ssh_public_key.SshKey.name
	Tag = local.AppTag
	UserEmailTag = local.UserEmailTag
	UserLoginTag = local.UserLoginTag
	UserProjectTag = local.UserProjectTag
	Version = local.AppVersion
	VmSize = local.AgentVmSize
	init_cli = data.cloudinit_config.init_cli.rendered
	depends_on = [
		azurerm_ssh_public_key.SshKey,
		module.Vnet
	]
}

module "Agent2" {
	source = "armdupre/module-keng-agent/azurerm"
	version = "0.1.0"
	Eth0IpAddress = local.Agent2Eth0IpAddress
	Eth0SubnetId = module.Vnet.PublicSubnet.id
	Eth1IpAddresses = local.Agent2Eth1IpAddresses
	Eth1SubnetId = module.Vnet.PrivateSubnet.id
	Eth2IpAddresses = local.Agent2Eth2IpAddresses
	Eth2SubnetId = module.Vnet.PrivateSubnet.id
	Eth3IpAddresses = local.Agent2Eth3IpAddresses
	Eth3SubnetId = module.Vnet.PrivateSubnet.id
	Eth4IpAddresses = local.Agent2Eth4IpAddresses
	Eth4SubnetId = module.Vnet.PrivateSubnet.id
	InstanceId = local.Agent2InstanceId
	ResourceGroupLocation = azurerm_resource_group.ResourceGroup.location
	ResourceGroupName = azurerm_resource_group.ResourceGroup.name
	SleepDelay = local.SleepDelay
	SshKeyName = azurerm_ssh_public_key.SshKey.name
	Tag = local.AppTag
	UserEmailTag = local.UserEmailTag
	UserLoginTag = local.UserLoginTag
	UserProjectTag = local.UserProjectTag
	Version = local.AppVersion
	VmSize = local.AgentVmSize
	init_cli = data.cloudinit_config.init_cli.rendered
	depends_on = [
		azurerm_ssh_public_key.SshKey,
		module.Vnet
	]
}

resource "azurerm_resource_group" "ResourceGroup" {
	name = local.ResourceGroupName
	location = local.ResourceGroupLocation
}

resource "azurerm_role_assignment" "RoleAssignment" {
	scope = data.azurerm_subscription.current.id
	role_definition_name = "Reader"
	principal_id = module.Agent1.Instance.identity[0].principal_id
}

resource "random_id" "RandomId" {
	byte_length = 4
}