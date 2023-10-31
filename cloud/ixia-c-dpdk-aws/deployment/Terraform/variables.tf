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

variable "AwsAccessCredentialsAccessKey" {
	description = "Access key component of credentials used for programmatic calls to AWS."
	type = string
}

variable "AwsAccessCredentialsSecretKey" {
	description = "Secret access key component of credentials used for programmatic calls to AWS."
	type = string
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
	sensitive = true
	type = string
}

variable "InboundIPv4CidrBlocks" {
	description = "List of IP Addresses /32 or IP CIDR ranges connecting inbound to App"
	type = list(string)
}

variable "KengControllerImage" {
	default = "ghcr.io/open-traffic-generator/keng-controller:0.1.0-3"
	type = string
}

variable "KengTrafficEngineImage" {
	default = "ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85"
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

variable "UserEmailTag" {
	description = "Email address tag of user creating the deployment"
	type = string
	validation {
		condition = length(var.UserEmailTag) >= 14
		error_message = "UserEmailTag minimum length must be >= 14."
	}
}

variable "UserLoginTag" {
	description = "Login ID tag of user creating the deployment"
	type = string
	validation {
		condition = length(var.UserLoginTag) >= 4
		error_message = "UserLoginTag minimum length must be >= 4."
	}
}

variable "UserProjectTag" {
	default = "cloud-ist"
	description = "Project tag of user creating the deployment"
	type = string
}