SHELL = /bin/bash

.PHONY: all
all: install pull deploy run

.PHONY: clean
clean: remove-lab

.PHONY: clean-all
clean-all: clean install-clean

###############################
# Install components
###############################

.PHONY: install
install: install-docker-compose

install-docker-compose: /usr/local/bin/docker-compose
/usr/local/bin/docker-compose:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	
install-clean:
	-sudo rm -f `command -v docker-compose`

###############################
# Pull images
###############################

.PHONY: pull
pull: pull-public pull-private

pull-public:
	docker-compose pull traffic_engine_1
	
pull-private: docker-login
	docker-compose pull controller protocol_engine_1

docker-login:
	@if [ -n "${GITHUB_USER}" ] && [ -n "${GITHUB_PAT}" ]; then echo "${GITHUB_PAT}" | docker login -u"${GITHUB_USER}" --password-stdin ghcr.io; fi
	

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-lab deploy-net

deploy-lab:
	sudo docker-compose up -d

deploy-net:
	sudo ../../utils/connect_containers_veth.sh cpdp-b2b_traffic_engine_1_1 cpdp-b2b_traffic_engine_2_1 veth0 veth1

remove-lab:
	docker-compose down

###############################
# Run tests
###############################

.PHONY: run
run: prerun gotest-run

# pause for ixia-c-controller to detect newly created interfaces
prerun:
	sleep 3
	sudo docker ps

gotest-run:
	cd tests; go test -run TestIPv4BGPRouteInstall
