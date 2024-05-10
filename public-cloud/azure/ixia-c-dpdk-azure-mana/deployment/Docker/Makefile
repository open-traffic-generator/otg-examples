SHELL = /bin/bash

KENG_Controller = "ghcr.io/open-traffic-generator/keng-controller:1.3.0-2"
IxiaC_TE = "ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.167"
GitRepoBasePath = "/home/ubuntu/otg-examples"
# GitRepoDeployPath = "$(GitRepoExecPath)/deployment"
GitRepoDeployPath = "$(GitRepoBasePath)/public-cloud/azure/ixia-c-dpdk-azure-mana/configs"
GitRepoExecPath = "$(GitRepoBasePath)/snappi/data-plane-performance"
GitRepoDPDK = "$(GitRepoBasePath)/public-cloud/azure/ixia-c-dpdk-azure-mana/deployment/DPDK

###############################
# Pull images
###############################

.PHONY: pull
pull: pull-keng-controller pull-ixia-c-traffic-engine

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

.PHONY: clean
clean: remove-keng-controller remove-ixia-c-traffic-engine

remove-keng-controller:
ifneq ($(shell sudo docker images -q keng-controller:latest 2> /dev/null),)
	docker rmi `docker images -q keng-controller:latest 2> /dev/null` --force
endif

remove-ixia-c-traffic-engine:
ifneq ($(shell sudo docker images -q ixia-c-traffic-engine:latest 2> /dev/null),)
	docker rmi `docker images -q ixia-c-traffic-engine:latest 2> /dev/null` --force
endif


###############################
# set config files
###############################
.PHONY: config
config:
	scp -o StrictHostKeyChecking=no -i /home/ubuntu/.sshkey.pem ubuntu@10.0.10.12:/home/ubuntu/otg-examples/public-cloud/azure/ixia-c-dpdk-azure-mana/configs/.env $(GitRepoDPDK)/.agent2
        cat /home/ubuntu/otg-examples/public-cloud/azure/ixia-c-dpdk-azure-mana/configs/.env > $(GitRepoDPDK)/.agent1
	chmod +x $(GitRepoDPDK)/set_config.sh
        $(GitRepoDPDK)/set_config.sh

###############################
# Compose Docker
###############################

.PHONY: docker-compose
docker-compose:
	sudo -H -u ubuntu bash -c 'docker-compose -f $(GitRepoDeployPath)/docker-compose.yaml up -d'
	sleep 2
	sudo -H -u ubuntu bash -c 'docker-compose -f $(GitRepoDeployPath)/docker-compose.yaml ps'

###############################
# Run tests
###############################
.PHONY: run
run: run-unidirectional 

.PHONY: run-unidirectional
run-unidirectional: config docker-compose 
	chmod +x $(GitRepoExecPath)/unidirectional.sh
	docker run --rm -t --net host -v $(GitRepoExecPath):/snappi --name snappi snappi:local bash -c "./unidirectional.sh -s 1500 -d downstream"

.PHONY: run-rfc2544
run-rfc2544: config docker-compose 
	chmod +x $(GitRepoExecPath)/rfc_2544.sh
	docker run --rm -t --net host -v $(GitRepoExecPath):/snappi --name snappi snappi:local bash -c "./rfc_2544.sh -s 1500 -d downstream"
