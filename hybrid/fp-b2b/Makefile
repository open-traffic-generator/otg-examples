SHELL = /bin/bash

KENG_Controller = "ghcr.io/open-traffic-generator/keng-controller:0.1.0-53"
OTG_gNMI = "ghcr.io/open-traffic-generator/otg-gnmi-server:1.13.0"
IxiaC_TE = "ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85"
IxiaC_PE = "ghcr.io/open-traffic-generator/ixia-c-protocol-engine:1.00.0.337"

export OTG_PORT1 = veth0
export OTG_PORT2 = veth1

.PHONY: all
all: install pull deploy start run

.PHONY: clean
clean: stop undeploy

.PHONY: clean-all
clean-all: clean clean-pull uninstall

create-go-cache:
	mkdir -p $$HOME/.cache/go-build

###############################
# Install components
###############################

.PHONY: install
install: install-envsubst

install-envsubst: /usr/bin/envsubst
/usr/bin/envsubst:
	sudo apt install gettext-base -y

uninstall:
	-sudo apt remove gettext-base -y

###############################
# Pull images
###############################

.PHONY: pull

pull: pull-keng
pull-keng: pull-keng-controller pull-otg-gnmi-server pull-ixia-c-traffic-engine pull-ixia-c-protocol-engine

clean-pull: remove-keng
remove-keng: remove-keng-controller remove-otg-gnmi-server remove-ixia-c-traffic-engine remove-ixia-c-protocol-engine

pull-ixia-c-operator:
	sudo -E docker compose pull operator

pull-keng-controller:
ifeq ($(shell sudo docker images -q keng-controller:latest 2> /dev/null),)
	-docker pull $(KENG_Controller)
	docker tag $(KENG_Controller) keng-controller:latest
endif

remove-keng-controller:
ifneq ($(shell sudo docker images -q keng-controller:latest 2> /dev/null),)
	docker rmi `docker images -q keng-controller:latest 2> /dev/null` --force
endif

pull-otg-gnmi-server:
ifeq ($(shell sudo docker images -q otg-gnmi-server:latest 2> /dev/null),)
	-docker pull $(OTG_gNMI)
	docker tag $(OTG_gNMI) otg-gnmi-server:latest
endif

remove-otg-gnmi-server:
ifneq ($(shell sudo docker images -q otg-gnmi-server:latest 2> /dev/null),)
	docker rmi `docker images -q otg-gnmi-server:latest 2> /dev/null` --force
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

pull-ixia-c-protocol-engine:
ifeq ($(shell sudo docker images -q ixia-c-protocol-engine:latest 2> /dev/null),)
	-docker pull $(IxiaC_PE)
	docker tag $(IxiaC_PE) ixia-c-protocol-engine:latest
endif

remove-ixia-c-protocol-engine:
ifneq ($(shell sudo docker images -q ixia-c-protocol-engine:latest 2> /dev/null),)
	docker rmi `docker images -q ixia-c-protocol-engine:latest 2> /dev/null` --force
endif

###############################
# Deploy operator
###############################

.PHONY: deploy
deploy: deploy-operator
undeploy: remove-operator

deploy-operator:
	sudo -E docker compose up -d
	sleep 10
	curl --data-binary @"ixiatg-configmap.yml" http://localhost:35000/config

remove-operator:
	sudo -E docker compose down

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

run: run-fp-otg-b2b

run-fp-otg-b2b:
	cd featureprofiles/feature/experimental/otg_only && \
	go test -v otgb2b_test.go -testbed otgb2b.testbed -binding "../../../../otgb2b.binding"
