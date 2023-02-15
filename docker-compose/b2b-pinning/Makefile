SHELL = /bin/bash

.PHONY: all
all: install network deploy run

.PHONY: all-nopinning
all: install network deploy-nopinning run

.PHONY: clean
clean: remove-lab network-clean

.PHONY: clean-nopinning
clean: remove-lab-nopinning network-clean

.PHONY: clean-all
clean-all: clean clean-nopinning install-clean

###############################
# Install components
###############################

.PHONY: install
install: install-docker-compose install-otgen

install-docker-compose: /usr/local/bin/docker-compose
/usr/local/bin/docker-compose:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	
install-otgen: /usr/local/bin/otgen
/usr/local/bin/otgen:
	bash -c "$$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.4.0

install-clean:
	-sudo rm -f `command -v docker-compose`
	-sudo rm -f `command -v otgen`

###############################
# Test network
###############################

.PHONY: network
network:veth0

veth0: /sys/class/net/veth0
/sys/class/net/veth0:
	sudo ip link add name veth0 type veth peer name veth1
	sudo ip link set dev veth0 up
	sudo ip link set dev veth1 up

network-clean: veth0-clean
veth0-clean:
	-sudo ip link del name veth0 type veth peer name veth1

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-lab

.PHONY: deploy-nopinning
deploy: deploy-lab-nopinning

deploy-lab:
	sudo docker-compose up -d 

remove-lab:
	-sudo docker-compose down

deploy-lab-nopinning:
	sudo docker-compose -f compose.nopinning.yml up -d

remove-lab-nopinning:
	-sudo docker-compose -f compose.nopinning.yml down


###############################
# Run tests
###############################

.PHONY: run
run: otgen-run

otgen-run:
	otgen run -f otg.yml -k --api https://localhost:8443 -m flow | otgen transform -m flow -c pps | otgen display -m table
