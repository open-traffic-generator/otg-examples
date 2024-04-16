SHELL = /bin/bash

GitRepoBasePath = "/home/ubuntu/keng-python/public-cloud/aws/ixia-c-dpdk-aws"
GitRepoExecPath = "$(GitRepoBasePath)/application/"

###############################
# Build components
###############################

.PHONY: build
build:
ifeq ($(shell sudo docker images -q snappi:local 2> /dev/null),)
	-docker build -t snappi:local $(GitRepoExecPath)/py
endif