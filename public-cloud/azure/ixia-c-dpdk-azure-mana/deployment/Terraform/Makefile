SHELL := /bin/bash

all: init apply

clean: destroy

init:
	terraform init

apply:
	time terraform apply -auto-approve

destroy:
	time terraform destroy -auto-approve