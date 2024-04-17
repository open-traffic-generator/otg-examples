variable "AgentInstanceType" {
	default = "c5.4xlarge"
	description = "Instance type of Agent VM"
	type = string
	validation {
		condition = contains([	"c5.xlarge", "c5.2xlarge", "c5.4xlarge",
								"c4.8xlarge"
							], var.AgentInstanceType)
		error_message = <<EOF
AgentInstanceType must be one of the following types:
	c5.xlarge, c5.2xlarge, c5.4xlarge,
	c4.8xlarge
		EOF
	}
}

variable "ApiMaxRetries" {
	default = 1
	type = number
}

variable "AwsMetadataServerUrl" {
	default = "http://169.254.169.254/latest/meta-data"
	type = string
}

variable "GitRepoName" {
	default = "keng-python"
	type = string
}

variable "GitRepoUrl" {
	default = "-b cloud https://github.com/open-traffic-generator/otg-examples.git"
	sensitive = true
	type = string
}

variable "PrivateSubnetAvailabilityZone" {
	default = "us-east-1a"
	type = string
}

variable "PublicSubnetAvailabilityZone" {
	default = "us-east-1a"
	type = string
}

variable "Region" {
	default = "us-east-1"
	type = string
}