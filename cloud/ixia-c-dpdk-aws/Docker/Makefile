SHELL = /bin/bash

KENG_Controller = "ghcr.io/open-traffic-generator/keng-controller:0.1.0-3"
IxiaC_TE = "ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85"

###############################
# Pull images
###############################

.PHONY: all
all: pull-keng-controller pull-ixia-c-traffic-engine

clean: remove-keng-controller remove-ixia-c-traffic-engine

pull-keng-controller:
ifeq ($(shell sudo docker images -q keng-controller:latest 2> /dev/null),)
	-docker pull $(KENG_Controller)
	docker tag $(KENG_Controller) keng-controller:latest
endif

ifeq ($(shell sudo docker images -q ixia-c-traffic-engine:latest 2> /dev/null),)
	-docker pull $(IxiaC_TE)
	docker tag $(IxiaC_TE) ixia-c-traffic-engine:latest
endif

.PHONY clean
clean: remove-keng-controller remove-ixia-c-traffic-engine

remove-keng-controller:
ifneq ($(shell sudo docker images -q keng-controller:latest 2> /dev/null),)
	docker rmi `docker images -q keng-controller:latest 2> /dev/null` --force
endif

remove-ixia-c-traffic-engine:
ifneq ($(shell sudo docker images -q ixia-c-traffic-engine:latest 2> /dev/null),)
	docker rmi `docker images -q keng-controller:latest 2> /dev/null` --force
endif