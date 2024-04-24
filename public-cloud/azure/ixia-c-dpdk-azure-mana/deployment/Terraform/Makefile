SHELL := /bin/bash

all: init apply

clean: destroy

init:
	time terraform init
	
plan:
	time terraform plan

apply:
	time terraform apply -auto-approve

destroy:
	time terraform destroy -auto-approve