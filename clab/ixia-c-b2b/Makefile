SHELL = /bin/bash

.PHONY: all
all: install build deploy run

.PHONY: clean
clean: remove-clab

.PHONY: clean-all
clean-all: clean build-clean install-clean

###############################
# Install components
###############################

.PHONY: install
install: install-clab

install-clab: /usr/bin/containerlab
/usr/bin/containerlab:
	bash -c "$$(curl -sL https://get.containerlab.dev)"

install-clean:
	-sudo apt remove containerlab -y

###############################
# Build components
###############################

.PHONY: build
build: build-snappi

build-snappi:
	sudo docker build -t snappi:local .

build-clean:
	-sudo docker rmi snappi:local
	
###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-clab

deploy-clab:
	sudo -E containerlab deploy -t topo.yml --reconfigure

remove-clab:
	sudo containerlab destroy -t topo.yml --cleanup

###############################
# Run tests
###############################

.PHONY: run
run: run-snappi run-scapy run-scapy-port

run-snappi:
	sudo docker exec clab-ixcb2b-snappi bash -c "python otg.py"

run-scapy:
	sudo docker exec clab-ixcb2b-snappi bash -c "OTG_API='https://clab-ixcb2b-ixia-c:8443' OTG_LOCATION_P1=eth1 OTG_LOCATION_P2=eth2 python scapy2otg.py"

run-scapy-port:
	sudo docker exec clab-ixcb2b-snappi bash -c "OTG_API='https://clab-ixcb2b-ixia-c:8443' OTG_LOCATION_P1=eth1 OTG_LOCATION_P2=eth2 python scapy2otg-port.py"