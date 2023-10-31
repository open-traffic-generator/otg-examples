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
			GitRepoExecPath: local.GitRepoExecPath
			GitRepoName: local.GitRepoName
			GitRepoUrl: local.GitRepoUrl
			KengControllerImage: local.KengControllerImage
			KengTrafficEngineImage: local.KengTrafficEngineImage
			UserName: local.AppTag
		})
	}	
	part {
		filename = "script-001"
		content_type = "text/cloud-config"
		content = templatefile("cloud-init.aws.yml", {
			Agent1Eth1PrivateIpAddresses: local.Agent1Eth1PrivateIpAddresses
			Agent2Eth1PrivateIpAddresses: local.Agent2Eth1PrivateIpAddresses
			AwsMetadataServerUrl: local.AwsMetadataServerUrl
			GitRepoConfigPath: local.GitRepoConfigPath
			GitRepoExecPath: local.GitRepoExecPath
			GitRepoName: local.GitRepoName
			UserName: local.AppTag
		})
	}	
}