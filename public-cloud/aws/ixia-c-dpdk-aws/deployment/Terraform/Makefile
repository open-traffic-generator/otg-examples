SHELL := /bin/bash

all: install init apply

clean: install destroy

install:
ifeq ($(shell grep "^ID=" /etc/*elease | cut -d "=" -f 2| sed -e 's/^"//' -e 's/"$$//' 2> /dev/null), amzn)
ifeq ($(shell command -v terraform 2> /dev/null),)
	sudo yum install -y yum-utils
	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
	sudo yum -y install terraform
endif
else
	$(error "ERROR: This lab requires the commands to be executed from within [AWS CloudShell]")
endif

init:
	time terraform init

plan:
	time terraform plan

apply:
	time terraform apply -auto-approve

destroy:
	time terraform destroy -auto-approve