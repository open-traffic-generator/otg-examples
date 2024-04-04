###############################
# Build components
###############################

.PHONY: build
build:
ifeq ($(shell sudo docker images -q snappi:local 2> /dev/null),)
	-docker build -t snappi:local /home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/py
endif