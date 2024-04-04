all: install init variables apply connect

clean: destroy

install:
ifeq ($(shell grep "^ID=" /etc/*elease | cut -d "=" -f 2| sed -e 's/^"//' -e 's/"$$//' 2> /dev/null), "amzn")
ifeq ($(shell command -v terraform 2> /dev/null),)
	sudo yum install -y yum-utils
	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
	sudo yum -y install terraform
endif
endif

init:
	terraform init

variables:
	cat terraform.required.auto.tfvars | sed 's/# //g' | sed "s/1.1.1.1/$$(curl --silent ifconfig.me)/" > terraform.auto.tfvars

apply:
	terraform apply -auto-approve

connect:
	terraform output SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" | sudo tee SshKey.pem > /dev/null
	sudo chmod 400 SshKey.pem
	sudo ssh -i SshKey.pem ubuntu@$$(terraform output -json Agent1Eth0ElasticIp | jq -r .public_dns)

destroy:
	terraform destroy -auto-approve