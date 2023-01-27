SHELL = /bin/bash

export OTG_PORT1 = veth0
export OTG_PORT2 = veth1

.PHONY: all
all: install pull deploy start run

.PHONY: clean
clean: stop undeploy

.PHONY: clean-all
clean-all: clean pull-clean uninstall

###############################
# Install components
###############################

.PHONY: install
install: install-docker-compose install-envsubst

install-docker-compose: /usr/local/bin/docker-compose
/usr/local/bin/docker-compose:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

install-envsubst: /usr/bin/envsubst
/usr/bin/envsubst:
	sudo apt install gettext-base -y

uninstall:
	-sudo rm -f `command -v docker-compose`
	-sudo apt remove gettext-base -y

###############################
# Pull images
###############################

.PHONY: pull

pull: pull-keng
pull-keng: pull-ixia-c-operator pull-ixia-c-controller pull-ixia-c-gnmi-server pull-ixia-c-traffic-engine pull-ixia-c-protocol-engine pull-feature-profiles

pull-clean: remove-keng
remove-keng: remove-ixia-c-controller remove-ixia-c-gnmi-server remove-ixia-c-traffic-engine remove-ixia-c-protocol-engine remove-feature-profiles

pull-ixia-c-operator:
	sudo -E docker-compose pull operator

pull-ixia-c-controller:
ifeq ($(shell sudo docker images -q ixia-c-controller:latest 2> /dev/null),)
	-sudo -E docker pull ghcr.io/open-traffic-generator/licensed/ixia-c-controller:0.0.1-3724
	sudo -E docker tag ghcr.io/open-traffic-generator/licensed/ixia-c-controller:0.0.1-3724 ixia-c-controller:latest
endif

remove-ixia-c-controller:
ifneq ($(shell sudo docker images -q ixia-c-controller:latest 2> /dev/null),)
	sudo -E docker rmi `docker images -q ixia-c-controller:latest 2> /dev/null` --force
endif

pull-ixia-c-gnmi-server:
ifeq ($(shell sudo docker images -q ixia-c-gnmi-server:latest 2> /dev/null),)
	-sudo -E docker pull ghcr.io/open-traffic-generator/ixia-c-gnmi-server:1.10.6
	sudo -E docker tag ghcr.io/open-traffic-generator/ixia-c-gnmi-server:1.10.6 ixia-c-gnmi-server:latest
endif

remove-ixia-c-gnmi-server:
ifneq ($(shell sudo docker images -q ixia-c-gnmi-server:latest 2> /dev/null),)
	sudo -E docker rmi `docker images -q ixia-c-gnmi-server:latest 2> /dev/null` --force
endif

pull-ixia-c-traffic-engine:
ifeq ($(shell sudo docker images -q ixia-c-traffic-engine:latest 2> /dev/null),)
	-sudo -E docker pull ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.24
	sudo -E docker tag ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.24 ixia-c-traffic-engine:latest
endif

remove-ixia-c-traffic-engine:
ifneq ($(shell sudo docker images -q ixia-c-traffic-engine:latest 2> /dev/null),)
	sudo -E docker rmi `docker images -q ixia-c-traffic-engine:latest 2> /dev/null` --force
endif

pull-ixia-c-protocol-engine:
ifeq ($(shell sudo docker images -q ixia-c-protocol-engine:latest 2> /dev/null),)
	-sudo -E docker pull ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.256
	sudo -E docker tag ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.256 ixia-c-protocol-engine:latest
endif

remove-ixia-c-protocol-engine:
ifneq ($(shell sudo docker images -q ixia-c-protocol-engine:latest 2> /dev/null),)
	sudo -E docker rmi `docker images -q ixia-c-protocol-engine:latest 2> /dev/null` --force
endif

pull-feature-profiles: ./featureprofiles
./featureprofiles:
	git clone -b static --depth 1 https://github.com/open-traffic-generator/featureprofiles.git

remove-feature-profiles:
	-rm -r ./featureprofiles

###############################
# Deploy operator
###############################

.PHONY: deploy
deploy: deploy-operator
undeploy: remove-operator 

deploy-operator:
	sudo -E docker-compose up -d
	sleep 5
	curl --data-binary @"ixiatg-configmap.yml" http://localhost:35000/config

remove-operator:
	sudo -E docker-compose down

###############################
# Start lab
###############################

.PHONY: start
start: start-network start-ixia-c
stop: stop-ixia-c stop-network

start-network:OTG_PORT1

OTG_PORT1: /sys/class/net/$(OTG_PORT1)
/sys/class/net/veth0:
	sudo ip link add name $(OTG_PORT1) type veth peer name $(OTG_PORT2)
	sudo ip link set dev $(OTG_PORT1) up
	sudo ip link set dev $(OTG_PORT2) up

stop-network: OTG_PORT1-clean
OTG_PORT1-clean:
	-sudo ip link del name $(OTG_PORT1) type veth peer name $(OTG_PORT2)

start-ixia-c:
	cat "ixia-c-hybrid.yml" | envsubst | curl --data-binary @- http://localhost:35000/create

stop-ixia-c:
	-cat "ixia-c-hybrid.yml" | envsubst | curl --data-binary @- http://localhost:35000/delete

###############################
# Run tests
###############################

.PHONY: run
run:
	cd featureprofiles/feature/experimental/otg_only && \
	go test -v otgb2b_test.go -testbed otgb2b.testbed -binding "../../../../otgb2b.binding"
