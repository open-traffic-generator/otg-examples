output "AgentAmi" {
	value = {
		"image_id" : module.Agent1.Ami.image_id
		"name" : module.Agent1.Ami.name
		"owner_id" : module.Agent1.Ami.owner_id
	}
}

output "Agent1Eth0ElasticIp" {
	value = {
		"public_dns" : module.Agent1.Eth0ElasticIp.public_dns
		"public_ip" : module.Agent1.Eth0ElasticIp.public_ip
	}
}

output "Agent2Eth0ElasticIp" {
	value = {
		"public_dns" : module.Agent2.Eth0ElasticIp.public_dns
		"public_ip" : module.Agent2.Eth0ElasticIp.public_ip
	}
}

output "AvailabilityZones" {
	value = {
		"available.names" : data.aws_availability_zones.available.names
	}
}

output "SshKey" {
	sensitive = true
	value = {
		"private_key_openssh" : replace(tls_private_key.SshKey.private_key_openssh, "/\\s\\s/", "")
		"private_key_pem" : replace(tls_private_key.SshKey.private_key_pem, "  ", "")
		"public_key_openssh" : replace(tls_private_key.SshKey.public_key_openssh, "/\\s\\s/", "")
		"public_key_pem" : replace(tls_private_key.SshKey.public_key_pem, "/\\s\\s/", "")
	}
}