SHELL := /bin/bash

###############################
# Run Application
###############################

.PHONY: run
run:
	chmod +x *.sh
	./run.sh -i $$(terraform output -state ../Terraform/terraform.tfstate -json Agent1Eth0PublicIpAddress | jq -r .fqdn)

.PHONY: connect
connect: connect-agent1

connect-agent1:
	rm -f SshKey.pem
	terraform output -state ../Terraform/terraform.tfstate SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" | tee SshKey.pem > /dev/null
	chmod +x *.sh
	./connect.sh \
		-i $$(terraform output -state ../Terraform/terraform.tfstate -json Agent1Eth0PublicIpAddress | jq -r .fqdn) \
		-k SshKey.pem

connect-agent2:
	rm -f SshKey.pem
	terraform output -state ../Terraform/terraform.tfstate SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" | tee SshKey.pem > /dev/null
	chmod +x *.sh
	./connect.sh \
		-i $$(terraform output -state ../Terraform/terraform.tfstate -json Agent2Eth0PublicIpAddress | jq -r .fqdn) \
		-k SshKey.pem