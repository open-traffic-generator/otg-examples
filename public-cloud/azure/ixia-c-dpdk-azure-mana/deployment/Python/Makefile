SHELL = /bin/bash

GitRepoBasePath = "/home/ubuntu/keng-python/public-cloud/aws/ixia-c-dpdk-aws"
GitRepoExecPath = "$(GitRepoBasePath)/application/"
GitRepoSourcePath = "/home/ubuntu/keng-python/snappi/data-plane-performance"

###############################
# Build components
###############################

.PHONY: build
build:
ifeq ($(shell sudo docker images -q snappi:local 2> /dev/null),)
	cp $(GitRepoSourcePath)/py/requirements.txt $(GitRepoExecPath)/py
	docker build -t snappi:local $(GitRepoExecPath)/py
endif