SHELL = /bin/bash

KENG_Controller = "ghcr.io/open-traffic-generator/keng-controller:0.1.0-3"
IxiaC_TE = "ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85"

.PHONY: prereqs
prereqs: build pull


###############################
# Build components
###############################

.PHONY: build
build: build-snappi

build-snappi:
ifeq ($(shell sudo docker images -q snappi:local 2> /dev/null),)
	docker build -t snappi:local /home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/py
endif

###############################
# Pull images
###############################

.PHONY: pull

pull: pull-keng
pull-keng: pull-keng-controller pull-ixia-c-traffic-engine

pull-keng-controller:
ifeq ($(shell sudo docker images -q keng-controller:latest 2> /dev/null),)
        -docker pull $(KENG_Controller)
        docker tag $(KENG_Controller) keng-controller:latest
endif

pull-ixia-c-traffic-engine:
ifeq ($(shell sudo docker images -q ixia-c-traffic-engine:latest 2> /dev/null),)
        -docker pull $(IxiaC_TE)
        docker tag $(IxiaC_TE) ixia-c-traffic-engine:latest
endif
