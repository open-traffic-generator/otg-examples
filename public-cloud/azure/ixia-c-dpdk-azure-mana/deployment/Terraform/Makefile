SHELL := /bin/bash

all: init apply

clean: destroy

init:
	time terraform init
	
plan:
	time terraform plan

apply:
	time terraform apply -auto-approve
	rm .sshkey.pem
	terraform output -state terraform.tfstate SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" > .sshkey.pem
	chmod 400 .sshkey.pem
	scp -i .sshkey.pem .sshkey.pem ubuntu@$$(terraform output -state deployment/Terraform/terraform.tfstate -json Agent2Eth0PublicIpAddress | jq -r .fqdn):.
	

destroy:
	time terraform destroy -auto-approve
