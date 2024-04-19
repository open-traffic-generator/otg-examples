SHELL := /bin/bash

all: init apply

clean: destroy

init:
	terraform init

apply:
	time terraform apply -auto-approve

connect:
	terraform output SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" | sudo tee SshKey.pem > /dev/null
	sudo chmod 400 SshKey.pem
	sudo ssh -i SshKey.pem ubuntu@$$(terraform output -json Agent1Eth0PublicIpAddress | jq -r .fqdn)

destroy:
	time terraform destroy -auto-approve