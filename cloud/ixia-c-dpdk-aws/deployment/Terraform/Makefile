deploy: init apply

init:
	terraform init
	
variables:
	cat terraform.required.auto.tfvars | sed 's/# Inbound/Inbound/' | sed 's/# User/User/' | sed "s/1.1.1.1/$$(curl --silent ifconfig.me)/" > terraform.auto.tfvars

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

ssh-agent1:
	terraform output SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" | sudo tee SshKey.pem > /dev/null
	sudo chmod 400 SshKey.pem
	ssh -i SshKey.pem ubuntu@$$(terraform output -json Agent1Eth0ElasticIp | jq -r .public_dns)

ssh-agent2:
	terraform output SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" > SshKey.pem
	chmod 400 SshKey.pem
	ssh -i SshKey.pem ubuntu@$$(terraform output -json Agent2Eth0ElasticIp | jq -r .public_dns)