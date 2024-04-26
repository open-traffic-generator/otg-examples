data "azurerm_ssh_public_key" "SshKey" {
	name = local.SshKeyName
	resource_group_name = local.ResourceGroupName
}