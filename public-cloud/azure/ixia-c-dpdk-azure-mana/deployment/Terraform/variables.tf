variable "AgentVmSize" {
	default = "Standard_F8s_v2"
	description = "Category, series and instance specifications associated with the VM"
	type = string
	validation {
		condition = contains([	"Standard_F8s_v2",
								"Experimental_Boost8"
							], var.AgentVmSize)
		error_message = <<EOF
AgentVmSize must be one of the following sizes:
	Standard_F8s_v2,
	Experimental_Boost8
		EOF
	}
}

variable "ResourceGroupLocation" {
	default = "South Central US"
	type = string
}

variable "SubscriptionId" {
	sensitive = true
	type = string
}