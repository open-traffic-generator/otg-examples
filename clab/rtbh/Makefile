SHELL = /bin/bash

.PHONY: all
all: install docker deploy run

.PHONY: clean
clean: remove-lab

.PHONY: clean-all
clean-all: clean install-clean

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
# Docker images
###############################

.PHONY: docker
docker: docker-gosnappi
docker-gosnappi:
	sudo docker build -t gosnappi:local .

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-lab

deploy-lab:
	sudo -E containerlab deploy --reconfigure -t topo.yml

remove-lab:
	sudo -E containerlab destroy -t topo.yml

###############################
# Run tests
###############################

.PHONY: run
run: gosnappi-run

gosnappi-run:
	#sudo docker exec -t clab-rtbh-gosnappi bash -c "go test -dstMac=$$(sudo docker exec clab-rtbh-pe-router vtysh -c  'sh interface eth2 | include HWaddr' | awk '{print $$2}')"
	go test -dstMac=$$(sudo docker exec clab-rtbh-pe-router vtysh -c  'sh interface eth2 | include HWaddr' | awk '{print $$2}')
