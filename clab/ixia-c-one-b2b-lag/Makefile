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
install: install-clab install-otgen

install-clab: /usr/bin/containerlab
/usr/bin/containerlab:
	bash -c "$$(curl -sL https://get.containerlab.dev)"

install-otgen: /usr/local/bin/otgen
/usr/local/bin/otgen:
	bash -c "$$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.4.0

install-clean:
	-sudo rm -f `command -v otgen`
	-sudo apt remove containerlab -y

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
run: run-otgen

export OTG_API=https://clab-ixcb2b-lag-ixia-c:8443

run-otgen:
#	sleep 5 # pause for all components to initialize
	otgen --log debug run --insecure --file otg.yaml --yaml --metrics flow | otgen transform --metrics flow
	otgen --log debug run --insecure --file otg.yaml --yaml --metrics port | otgen transform --metrics port
