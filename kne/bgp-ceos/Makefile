SHELL = /bin/bash

KENG_Controller = "ghcr.io/open-traffic-generator/keng-controller:0.1.0-3"
OTG_gNMI = "ghcr.io/open-traffic-generator/otg-gnmi-server:1.13.0"
IxiaC_TE = "ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85"
IxiaC_PE = "ghcr.io/open-traffic-generator/ixia-c-protocol-engine:1.00.0.337"

cEOSLab = "ceos:latest"

otgen_version = 0.6.2
otgen_image = otgen:$(otgen_version)

#kne_repo = "https://github.com/openconfig/kne.git"
kne_repo = "https://github.com/open-traffic-generator/kne.git"
kne_version = "dev-keng-operator"

.PHONY: prereqs
prereqs: install build pull

.PHONY: all
all: prereqs deploy start run

.PHONY: clean
clean: stop undeploy

.PHONY: clean-all
clean-all: clean clean-pull clean-build uninstall

###############################
# Install components
###############################

.PHONY: install
install: install-go install-kubectl install-kind

install-go: /usr/local/go/bin/go
/usr/local/go/bin/go:
	curl -sLO https://go.dev/dl/go1.21.3.linux-amd64.tar.gz
	sudo tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz
	sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
	rm go1.21.3.linux-amd64.tar.gz

install-kubectl: /usr/local/bin/kubectl
/usr/local/bin/kubectl:
	curl -sLO https://dl.k8s.io/release/v1.24.1/bin/linux/amd64/kubectl
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	rm kubectl

install-kind: /usr/local/bin/kind
/usr/local/bin/kind:
	go install sigs.k8s.io/kind@v0.19.0
	sudo install -o root -g root -m 0755 $(HOME)/go/bin/kind /usr/local/bin/kind

uninstall:
	-sudo rm -f `command -v kind`
	-sudo rm -f `command -v kubectl`
	-sudo apt remove docker.io
	-sudo rm -rf /usr/local/go

###############################
# Build components
###############################

.PHONY: build
.PHONY: clean-build
build: build-kne build-otgen

build-kne: /usr/local/bin/kne
/usr/local/bin/kne:
	rm -rf ./kne
	git clone --branch $(kne_version) $(kne_repo)
	cd kne && make build
	sudo install -o root -g root -m 0755 kne/kne /usr/local/bin/kne

build-otgen:
ifeq ($(shell sudo docker images -q $(otgen_image) 2> /dev/null),)
	docker build -t $(otgen_image) -f Dockerfile.otgen --build-arg version=$(otgen_version) .
	docker tag $(otgen_image) otgen:local
endif

clean-build:
	-docker rmi $(otgen_image)
	-sudo rm -f `command -v kne`
	-rm -rf ./kne

###############################
# Pull images
###############################

.PHONY: pull

pull: pull-keng
pull-keng: pull-keng-controller pull-otg-gnmi-server pull-ixia-c-traffic-engine pull-ixia-c-protocol-engine

clean-pull: remove-keng
remove-keng: remove-keng-controller remove-otg-gnmi-server remove-ixia-c-traffic-engine remove-ixia-c-protocol-engine

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
# Deploy cluster
###############################

.PHONY: deploy
deploy: deploy-cluster load-images
undeploy: remove-cluster

deploy-cluster:
	kne deploy kne/deploy/kne/kind-bridge.yaml

load-images:
	kind load docker-image $(KENG_Controller) --name=kne
	kind load docker-image $(OTG_gNMI) --name=kne
	kind load docker-image $(IxiaC_TE) --name=kne
	kind load docker-image $(IxiaC_PE) --name=kne
	kind load docker-image $(cEOSLab) --name=kne
	kind load docker-image otgen:local --name=kne

remove-cluster:
	kind delete cluster --name kne

###############################
# Start labs
###############################

.PHONY: start
.PHONY: stop
start: start-topo-keng-ceos
stop: stop-topo-keng-ceos

start-topo-keng-ceos:
	kne create keng-ceos.pb.txt

stop-topo-keng-ceos:
	-kne delete keng-ceos.pb.txt

###############################
# Run tests
###############################

.PHONY: run

run: run-otgen-bgp

run-otgen-bgp:
	kubectl create -f job-otgen-bgp.yaml
	sleep 2
	kubectl get job -l testcase=otgen-bgp --sort-by='{.metadata.creationTimestamp}' -o name | tac | head -1 | xargs kubectl logs -f
