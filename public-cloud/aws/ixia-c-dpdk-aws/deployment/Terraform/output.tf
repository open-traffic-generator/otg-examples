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