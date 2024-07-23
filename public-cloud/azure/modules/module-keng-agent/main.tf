resource "azurerm_linux_virtual_machine" "Instance" {
	name = local.InstanceName
	location = local.ResourceGroupLocation
	resource_group_name = local.ResourceGroupName
	tags = {
		Name = local.InstanceName
		Owner = local.UserEmailTag
		Project = local.UserProjectTag
		ResourceGroup = local.ResourceGroupName
		Location = local.ResourceGroupLocation
	}
	size = local.VmSize
	source_image_reference {
		publisher = local.MarketplaceImagePublisherId
		offer = local.MarketplaceImageOfferId
		sku = local.ImageSku
		version = local.ImageVersion
	}
	os_disk {
		caching = "ReadWrite"
		storage_account_type = "Standard_LRS"
	}
	computer_name = replace(local.InstanceName, "_", "-")
	admin_username = local.AdminUserName
	disable_password_authentication = local.DisablePasswordAuthentication
	admin_ssh_key {
		username = local.AdminUserName
		public_key = data.azurerm_ssh_public_key.SshKey.public_key
	}
	custom_data = base64encode(local.init_cli)
	network_interface_ids = [
		azurerm_network_interface.Eth0.id,
		azurerm_network_interface.Eth1.id,
		azurerm_network_interface.Eth2.id,
		azurerm_network_interface.Eth3.id,
		azurerm_network_interface.Eth4.id,
		azurerm_network_interface.Eth5.id,
		azurerm_network_interface.Eth6.id,
		azurerm_network_interface.Eth7.id
	]
	boot_diagnostics {}
	identity {
		type = "SystemAssigned"
	}	
	depends_on = [
		azurerm_network_interface.Eth0,
		azurerm_network_interface.Eth1,
		azurerm_network_interface.Eth2,
		azurerm_network_interface.Eth3,
		azurerm_network_interface.Eth4,
		azurerm_network_interface.Eth5,
		azurerm_network_interface.Eth6,
		azurerm_network_interface.Eth7
	]
	timeouts {
		create = "5m"
		delete = "10m"
	}
}

resource "azurerm_network_interface" "Eth0" {
	name = local.Eth0Name
	location = local.ResourceGroupLocation
	resource_group_name = local.ResourceGroupName
	tags = {
		Owner = local.UserEmailTag
		Project = local.UserProjectTag
		ResourceGroup = local.ResourceGroupName
		Location = local.ResourceGroupLocation
	}
	ip_configuration {
		name = "ipconfig1"
		private_ip_address = local.Eth0IpAddress
		private_ip_address_allocation = "Static"
		public_ip_address_id = azurerm_public_ip.Eth0PublicIpAddress.id
		subnet_id = local.Eth0SubnetId
		primary = "true"
		private_ip_address_version = "IPv4"
	}
	dns_servers = []
	accelerated_networking_enabled = local.Eth0EnableAcceleratedNetworking
	enable_ip_forwarding = local.EnableIpForwarding
	depends_on = [
		azurerm_public_ip.Eth0PublicIpAddress
	]
}

resource "azurerm_network_interface" "Eth1" {
	name = local.Eth1Name
	location = local.ResourceGroupLocation
	resource_group_name = local.ResourceGroupName
	tags = {
		Owner = local.UserEmailTag
		Project = local.UserProjectTag
		ResourceGroup = local.ResourceGroupName
		Location = local.ResourceGroupLocation
	}
	dynamic "ip_configuration" {
		for_each = range(length(local.Eth1IpAddresses))
		iterator = index
		content {
			name = "ipconfig${index.value}"
			private_ip_address = local.Eth1IpAddresses[index.value]
			private_ip_address_allocation = "Static"
			subnet_id = local.Eth1SubnetId
			primary = index.value == 0 ? true : false
			private_ip_address_version = "IPv4"
		}
	}
	dns_servers = []
	accelerated_networking_enabled = local.Eth1EnableAcceleratedNetworking
	enable_ip_forwarding = local.EnableIpForwarding
}

resource "azurerm_network_interface" "Eth2" {
	name = local.Eth2Name
	location = local.ResourceGroupLocation
	resource_group_name = local.ResourceGroupName
	tags = {
		Owner = local.UserEmailTag
		Project = local.UserProjectTag
		ResourceGroup = local.ResourceGroupName
		Location = local.ResourceGroupLocation
	}
	dynamic "ip_configuration" {
		for_each = range(length(local.Eth2IpAddresses))
		iterator = index
		content {
			name = "ipconfig${index.value}"
			private_ip_address = local.Eth2IpAddresses[index.value]
			private_ip_address_allocation = "Static"
			subnet_id = local.Eth2SubnetId
			primary = index.value == 0 ? true : false
			private_ip_address_version = "IPv4"
		}
	}
	dns_servers = []
	accelerated_networking_enabled = local.Eth2EnableAcceleratedNetworking
	enable_ip_forwarding = local.EnableIpForwarding
}

resource "azurerm_network_interface" "Eth3" {
	name = local.Eth3Name
	location = local.ResourceGroupLocation
	resource_group_name = local.ResourceGroupName
	tags = {
		Owner = local.UserEmailTag
		Project = local.UserProjectTag
		ResourceGroup = local.ResourceGroupName
		Location = local.ResourceGroupLocation
	}
	dynamic "ip_configuration" {
		for_each = range(length(local.Eth3IpAddresses))
		iterator = index
		content {
			name = "ipconfig${index.value}"
			private_ip_address = local.Eth3IpAddresses[index.value]
			private_ip_address_allocation = "Static"
			subnet_id = local.Eth3SubnetId
			primary = index.value == 0 ? true : false
			private_ip_address_version = "IPv4"
		}
	}
	dns_servers = []
	accelerated_networking_enabled = local.Eth3EnableAcceleratedNetworking
	enable_ip_forwarding = local.EnableIpForwarding
}

resource "azurerm_network_interface" "Eth4" {
	name = local.Eth4Name
	location = local.ResourceGroupLocation
	resource_group_name = local.ResourceGroupName
	tags = {
		Owner = local.UserEmailTag
		Project = local.UserProjectTag
		ResourceGroup = local.ResourceGroupName
		Location = local.ResourceGroupLocation
	}
	dynamic "ip_configuration" {
		for_each = range(length(local.Eth4IpAddresses))
		iterator = index
		content {
			name = "ipconfig${index.value}"
			private_ip_address = local.Eth4IpAddresses[index.value]
			private_ip_address_allocation = "Static"
			subnet_id = local.Eth4SubnetId
			primary = index.value == 0 ? true : false
			private_ip_address_version = "IPv4"
		}
	}
	dns_servers = []
	accelerated_networking_enabled = local.Eth4EnableAcceleratedNetworking
	enable_ip_forwarding = local.EnableIpForwarding
}

resource "azurerm_network_interface" "Eth5" {
	name = local.Eth5Name
	location = local.ResourceGroupLocation
	resource_group_name = local.ResourceGroupName
	tags = {
		Owner = local.UserEmailTag
		Project = local.UserProjectTag
		ResourceGroup = local.ResourceGroupName
		Location = local.ResourceGroupLocation
	}
	dynamic "ip_configuration" {
		for_each = range(length(local.Eth5IpAddresses))
		iterator = index
		content {
			name = "ipconfig${index.value}"
			private_ip_address = local.Eth5IpAddresses[index.value]
			private_ip_address_allocation = "Static"
			subnet_id = local.Eth5SubnetId
			primary = index.value == 0 ? true : false
			private_ip_address_version = "IPv4"
		}
	}
	dns_servers = []
	accelerated_networking_enabled = local.Eth2EnableAcceleratedNetworking
	enable_ip_forwarding = local.EnableIpForwarding
}

resource "azurerm_network_interface" "Eth6" {
	name = local.Eth6Name
	location = local.ResourceGroupLocation
	resource_group_name = local.ResourceGroupName
	tags = {
		Owner = local.UserEmailTag
		Project = local.UserProjectTag
		ResourceGroup = local.ResourceGroupName
		Location = local.ResourceGroupLocation
	}
	dynamic "ip_configuration" {
		for_each = range(length(local.Eth6IpAddresses))
		iterator = index
		content {
			name = "ipconfig${index.value}"
			private_ip_address = local.Eth6IpAddresses[index.value]
			private_ip_address_allocation = "Static"
			subnet_id = local.Eth6SubnetId
			primary = index.value == 0 ? true : false
			private_ip_address_version = "IPv4"
		}
	}
	dns_servers = []
	accelerated_networking_enabled = local.Eth6EnableAcceleratedNetworking
	enable_ip_forwarding = local.EnableIpForwarding
}

resource "azurerm_network_interface" "Eth7" {
	name = local.Eth7Name
	location = local.ResourceGroupLocation
	resource_group_name = local.ResourceGroupName
	tags = {
		Owner = local.UserEmailTag
		Project = local.UserProjectTag
		ResourceGroup = local.ResourceGroupName
		Location = local.ResourceGroupLocation
	}
	dynamic "ip_configuration" {
		for_each = range(length(local.Eth7IpAddresses))
		iterator = index
		content {
			name = "ipconfig${index.value}"
			private_ip_address = local.Eth7IpAddresses[index.value]
			private_ip_address_allocation = "Static"
			subnet_id = local.Eth7SubnetId
			primary = index.value == 0 ? true : false
			private_ip_address_version = "IPv4"
		}
	}
	dns_servers = []
	accelerated_networking_enabled = local.Eth7EnableAcceleratedNetworking
	enable_ip_forwarding = local.EnableIpForwarding
}

resource "azurerm_public_ip" "Eth0PublicIpAddress" {
	name = local.Eth0PublicIpAddressName
	location = local.ResourceGroupLocation
	resource_group_name = local.ResourceGroupName
	tags = {
		Owner = local.UserEmailTag
		Project = local.UserProjectTag
		ResourceGroup = local.ResourceGroupName
		Location = local.ResourceGroupLocation
	}
	ip_version = "IPv4"
	allocation_method = "Static"
	idle_timeout_in_minutes = 4
	domain_name_label = local.DnsLabel
}

resource "time_sleep" "SleepDelay" {
	create_duration = local.SleepDelay
	depends_on = [
		azurerm_linux_virtual_machine.Instance
	]
}