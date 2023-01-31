SHELL = /bin/bash

IxiaC_Controller = "ghcr.io/open-traffic-generator/licensed/ixia-c-controller:0.0.1-3724"
IxiaC_gNMI = "ghcr.io/open-traffic-generator/ixia-c-gnmi-server:1.10.6"
IxiaC_TE = "ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.24"
IxiaC_PE = "ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.256"

.PHONY: all
all: install build pull deploy start

.PHONY: clean
clean: stop undeploy

.PHONY: clean-all
clean-all: clean clean-pull clean-build uninstall

###############################
# Install components
###############################

.PHONY: install
install: install-go install-kubectl install-kind

install-go:
	sudo snap install go --classic

install-kubectl: /usr/local/bin/kubectl
/usr/local/bin/kubectl:
	curl -sLO https://dl.k8s.io/release/v1.24.1/bin/linux/amd64/kubectl
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	rm kubectl

install-kind: /usr/local/bin/kind
/usr/local/bin/kind:
	go install sigs.k8s.io/kind@v0.14.0
	sudo install -o root -g root -m 0755 $(HOME)/go/bin/kind /usr/local/bin/kind

uninstall:
	-sudo rm -f `command -v kind`
	-sudo rm -f `command -v kubectl`
	-sudo apt remove docker.io
	-sudo snap remove go

###############################
# Build components
###############################

.PHONY: build
build: build-kne

build-kne: /usr/local/bin/kne
/usr/local/bin/kne:
	git clone --depth 1 https://github.com/openconfig/kne.git
	cd kne && make build
	sudo install -o root -g root -m 0755 kne/kne /usr/local/bin/kne

clean-build:
	-sudo rm -f `command -v kne`
	-rm -rf ./kne

###############################
# Pull images
###############################

.PHONY: pull

pull: pull-keng
pull-keng: pull-ixia-c-controller pull-ixia-c-gnmi-server pull-ixia-c-traffic-engine pull-ixia-c-protocol-engine

clean-pull: remove-keng
remove-keng: remove-ixia-c-controller remove-ixia-c-gnmi-server remove-ixia-c-traffic-engine remove-ixia-c-protocol-engine

pull-ixia-c-controller:
ifeq ($(shell sudo docker images -q ixia-c-controller:latest 2> /dev/null),)
	-docker pull $(IxiaC_Controller)
	docker tag $(IxiaC_Controller) ixia-c-controller:latest
endif

remove-ixia-c-controller:
ifneq ($(shell sudo docker images -q ixia-c-controller:latest 2> /dev/null),)
	docker rmi `docker images -q ixia-c-controller:latest 2> /dev/null` --force
endif

pull-ixia-c-gnmi-server:
ifeq ($(shell sudo docker images -q ixia-c-gnmi-server:latest 2> /dev/null),)
	-docker pull $(IxiaC_gNMI)
	docker tag $(IxiaC_gNMI) ixia-c-gnmi-server:latest
endif

remove-ixia-c-gnmi-server:
ifneq ($(shell sudo docker images -q ixia-c-gnmi-server:latest 2> /dev/null),)
	docker rmi `docker images -q ixia-c-gnmi-server:latest 2> /dev/null` --force
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
# Deploy cluster
###############################

.PHONY: deploy
deploy: deploy-cluster load-images
undeploy: remove-cluster 

deploy-cluster:
	kne deploy kind-bridge.yaml

load-images:
	kind load docker-image $(IxiaC_Controller) --name=kne
	kind load docker-image $(IxiaC_gNMI) --name=kne	
	kind load docker-image $(IxiaC_TE) --name=kne
	kind load docker-image $(IxiaC_PE) --name=kne

remove-cluster:
	kind delete cluster --name kne

###############################
# Start lab
###############################

.PHONY: start
start: start-topo
stop: stop-topo

start-topo:
	kne create 3node-ubuntu-host.pb.txt

stop-topo:
	kne delete 3node-ubuntu-host.pb.txt
