data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
	state = "available"
}

data "cloudinit_config" "init_cli" {
	gzip = true
	base64_encode = true
	part {
		content_type = "text/cloud-config"
		content = templatefile("cloud-init.yml", {
			GitRepoDeployPath: local.GitRepoDeployPath
			GitRepoName: local.GitRepoName
			GitRepoUrl: local.GitRepoUrl
			AgentUserName: local.AgentUserName
		})
	}
	part {
		filename = "script-001"
		content_type = "text/cloud-config"
		content = templatefile("cloud-init.aws.yml", {
			Agent1Eth1PrivateIpAddresses: local.Agent1Eth1PrivateIpAddresses
			Agent2Eth0IpAddress: local.Agent2Eth0PrivateIpAddress
			Agent2Eth1PrivateIpAddresses: local.Agent2Eth1PrivateIpAddresses
			AwsMetadataServerUrl: local.AwsMetadataServerUrl
			GitRepoConfigPath: local.GitRepoConfigPath
			GitRepoExecPath: local.GitRepoExecPath
			VpcId: module.Vpc.Vpc.id
		})
	}	
}

data "http" "ip" {
	url = "https://ifconfig.me"
}