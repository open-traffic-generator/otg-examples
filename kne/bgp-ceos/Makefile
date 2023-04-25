SHELL = /bin/bash

IxiaC_Controller = "ghcr.io/open-traffic-generator/licensed/ixia-c-controller:0.0.1-3889"
IxiaC_gNMI = "ghcr.io/open-traffic-generator/ixia-c-gnmi-server:1.11.5"
IxiaC_TE = "ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.35"
IxiaC_PE = "ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.290"

otgen_version = 0.5.0-rc1
otgen_image = otgen:$(otgen_version)

kne_version = v0.1.7

.PHONY: prereqs
prereqs: install build pull

.PHONY: all
all: prereqs deploy start-b2b run-b2b-otgen run-b2b-fp

.PHONY: clean
clean: stop-b2b undeploy

.PHONY: clean-all
clean-all: clean clean-pull clean-build uninstall

###############################
# Install components
###############################

.PHONY: install
install: install-go install-kubectl install-kind

install-go: /snap/bin/go
/snap/bin/go:
	sudo snap install go --classic

install-kubectl: /usr/local/bin/kubectl
/usr/local/bin/kubectl:
	curl -sLO https://dl.k8s.io/release/v1.24.1/bin/linux/amd64/kubectl
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	rm kubectl

install-kind: /usr/local/bin/kind
/usr/local/bin/kind:
	go install sigs.k8s.io/kind@v0.17.0
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
.PHONY: clean-build
build: build-kne build-otgen

build-kne: /usr/local/bin/kne
/usr/local/bin/kne:
	git clone --depth 1 --branch $(kne_version) https://github.com/openconfig/kne.git
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

pull: pull-keng pull-feature-profiles pull-lemming pull-feature-profiles-static
pull-keng: pull-ixia-c-controller pull-ixia-c-gnmi-server pull-ixia-c-traffic-engine pull-ixia-c-protocol-engine

clean-pull: remove-keng remove-feature-profiles remove-lemming remove-feature-profiles-static
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

pull-lemming: ./lemming
./lemming:
	git clone --depth 1 https://github.com/openconfig/lemming.git

remove-lemming:
	-rm -r ./lemming

pull-feature-profiles-static: ./featureprofiles-static
./featureprofiles-static:
	git clone --depth 1 -b static https://github.com/open-traffic-generator/featureprofiles.git featureprofiles-static

remove-feature-profiles-static:
	-rm -r ./featureprofiles-static

pull-feature-profiles: ./featureprofiles
./featureprofiles:
	git clone --depth 1 https://github.com/openconfig/featureprofiles.git

remove-feature-profiles:
	-rm -r ./featureprofiles

###############################
# Deploy cluster
###############################

.PHONY: deploy
deploy: deploy-cluster load-images apply-ixiatg-configmap deploy-operator-lemming
undeploy: remove-cluster

deploy-cluster:
	kne deploy kind-bridge.yaml

load-images:
	kind load docker-image $(IxiaC_Controller) --name=kne
	kind load docker-image $(IxiaC_gNMI) --name=kne
	kind load docker-image $(IxiaC_TE) --name=kne
	kind load docker-image $(IxiaC_PE) --name=kne
	kind load docker-image otgen:local --name=kne

apply-ixiatg-configmap:
	kubectl apply -f manifests/keysight/ixiatg-configmap.yaml

deploy-operator-lemming:
	kubectl apply -k lemming/operator/config/default

remove-cluster:
	kind delete cluster --name kne

###############################
# Start labs
###############################

.PHONY: start-b2b
.PHONY: stop-b2b
start-b2b: start-topo-keng-b2b
stop-b2b: stop-topo-keng-b2b

start-topo-keng-b2b:
	kne create ate-b2b.pb.txt

stop-topo-keng-b2b:
	kne delete ate-b2b.pb.txt

###############################
# Run tests
###############################

run-b2b-otgen:
	kubectl create -f job-otgen-flow-b2b.yaml
	sleep 2
	kubectl get job -l flow=b2b --sort-by='{.metadata.creationTimestamp}' -o name | tac | head -1 | xargs kubectl logs -f

run-b2b-fp:
	cd featureprofiles-static/feature/experimental/otg_only && \
	go test -v otgb2b_test.go -testbed otgb2b.testbed -kne-config "../../../../ate-b2b.ondatra.yaml"

run-lemming-tests:
	cd lemming && \
	go test ./integration_tests/...
