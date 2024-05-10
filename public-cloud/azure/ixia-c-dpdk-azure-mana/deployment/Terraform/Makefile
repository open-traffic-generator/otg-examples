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
	

destroy:
	time terraform destroy -auto-approve
