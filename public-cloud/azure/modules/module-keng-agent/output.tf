output "Eth0PublicIpAddress" {
	description = "Public ip address resource associated with the first network interface"
	value = {
		"fqdn" : azurerm_public_ip.Eth0PublicIpAddress.fqdn
		"ip_address" : azurerm_public_ip.Eth0PublicIpAddress.ip_address
	}
}

output "Instance" {
	description = "Instance resource associated with the virtual machine"
	value = {
		"admin_username" : azurerm_linux_virtual_machine.Instance.admin_username
		"computer_name" : azurerm_linux_virtual_machine.Instance.computer_name
		"disable_password_authentication" : azurerm_linux_virtual_machine.Instance.disable_password_authentication
		"identity" : azurerm_linux_virtual_machine.Instance.identity
		"location" : azurerm_linux_virtual_machine.Instance.location
		"name" : azurerm_linux_virtual_machine.Instance.name
		"os_disk" : azurerm_linux_virtual_machine.Instance.os_disk
		"plan" : azurerm_linux_virtual_machine.Instance.plan
		"private_ip_address" : azurerm_linux_virtual_machine.Instance.private_ip_address
		"provision_vm_agent" : azurerm_linux_virtual_machine.Instance.provision_vm_agent
		"resource_group_name" : azurerm_linux_virtual_machine.Instance.resource_group_name
		"size" : azurerm_linux_virtual_machine.Instance.size
		"source_image_reference" : azurerm_linux_virtual_machine.Instance.source_image_reference
	}
}