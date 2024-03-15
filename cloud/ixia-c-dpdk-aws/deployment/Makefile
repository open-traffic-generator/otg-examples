SHELL = /bin/bash

KENG_Controller = "ghcr.io/open-traffic-generator/keng-controller:0.1.0-3"
IxiaC_TE = "ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85"

###############################
# Infrastructure deployment
###############################

.PHONY: install
install:
	$(MAKE) -C Terraform deploy
	
.PHONY: connect
connect:
	$(MAKE) -C Terraform ssh-agent1

.PHONY: clean
clean:
	$(MAKE) -C Terraform destroy

.PHONY: prereqs
prereqs: build pull


###############################
# Build components
###############################

.PHONY: build
build: build-snappi

build-snappi:
ifeq ($(shell sudo docker images -q snappi:local 2> /dev/null),)
	-docker build -t snappi:local /home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/py
endif

###############################
# Pull images
###############################

.PHONY: pull

pull: pull-keng
pull-keng: pull-keng-controller pull-ixia-c-traffic-engine

clean-pull: remove-keng
remove-keng: remove-keng-controller remove-ixia-c-traffic-engine

pull-keng-controller:
ifeq ($(shell sudo docker images -q keng-controller:latest 2> /dev/null),)
	-docker pull $(KENG_Controller)
	docker tag $(KENG_Controller) keng-controller:latest
endif

remove-keng-controller:
ifneq ($(shell sudo docker images -q keng-controller:latest 2> /dev/null),)
	docker rmi `docker images -q keng-controller:latest 2> /dev/null` --force
endif

pull-ixia-c-traffic-engine:
ifeq ($(shell sudo docker images -q ixia-c-traffic-engine:latest 2> /dev/null),)
	-docker pull $(IxiaC_TE)
	docker tag $(IxiaC_TE) ixia-c-traffic-engine:latest
endif

remove-ixia-c-traffic-engine:
ifneq ($(shell sudo docker images -q ixia-c-traffic-engine:latest 2> /dev/null),)
	docker rmi `docker images -q ixia-c-traffic-engine:latest 2> /dev/null` --force
endif

###############################
# Enable DPDK
###############################

.PHONY: dpdk

dpdk:
	chmod +x /home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/deployment/*.sh
	/home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/deployment/setup_dpdk.sh

###############################
# Compose Docker
###############################

.PHONY: docker-compose

docker-compose:
	sudo -H -u ubuntu bash -c 'docker-compose -f /home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/deployment/docker-compose.yaml up -d'
	sudo -H -u ubuntu bash -c 'docker-compose -f /home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/deployment/docker-compose.yaml ps'

###############################
# Run tests
###############################

.PHONY: run

run: run-rfc2544
run-rfc2544:
	docker run --rm -t --net host -v $$(pwd):/snappi --name snappi snappi:local bash -c "./rfc2544_test_n_flows.sh -s 9000"
