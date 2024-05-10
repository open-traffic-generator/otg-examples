SHELL = /bin/bash

GitRepoBasePath = "/home/ubuntu/otg-examples"
GitRepoDeployPath = "$(GitRepoBasePath)/public-cloud/azure/community/deployment"
GitRepoExecPath = "$(GitRepoBasePath)/snappi/data-plane-performance"

###############################
# Build components
###############################

.PHONY: build
build:
ifeq ($(shell sudo docker images -q snappi:local 2> /dev/null),)
	cp $(GitRepoExecPath)/py/requirements.txt $(GitRepoDeployPath)/Python
	docker build -t snappi:local $(GitRepoDeployPath)/Python
endif
