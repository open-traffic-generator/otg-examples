SHELL = /bin/bash

KENG_Controller = "ghcr.io/open-traffic-generator/keng-controller:1.33.0-20"
IxiaC_TE = "ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.8.0.245"
GitRepoBasePath = "/home/ubuntu/keng-python"
GitRepoDeployPath = "$(GitRepoExecPath)/deployment"
GitRepoExecPath = "$(GitRepoBasePath)/snappi/data-plane-performance"

###############################
# Pull images
###############################

.PHONY: pull
pull: pull-keng-controller pull-ixia-c-traffic-engine

clean: remove-keng-controller remove-ixia-c-traffic-engine

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
# Compose Docker
###############################

.PHONY: docker-compose
docker-compose:
	sudo -H -u ubuntu bash -c 'docker-compose -f $(GitRepoDeployPath)/docker-compose.yaml up -d'
	sudo -H -u ubuntu bash -c 'docker-compose -f $(GitRepoDeployPath)/docker-compose.yaml ps'

###############################
# Run tests
###############################

.PHONY: run
run: run-rfc2544

run-rfc2544:
	chmod +x $(GitRepoExecPath)/rfc_2544.sh
	docker run --rm -t --net host -v $(GitRepoExecPath):/snappi --name snappi snappi:local bash -c "./rfc_2544.sh -s 9000"