SHELL = /bin/bash

.PHONY: all
all: install deploy run

.PHONY: clean
clean: remove-clab

.PHONY: clean-all
clean-all: clean install-clean

###############################
# Install components
###############################

.PHONY: install
install: install-clab install-otgen

install-clab: /usr/bin/containerlab
/usr/bin/containerlab:
	bash -c "$$(curl -sL https://get.containerlab.dev)" -- -v 0.46.2

install-otgen: /usr/local/bin/otgen
/usr/local/bin/otgen:
	bash -c "$$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.6.2

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

export OTG_API=https://clab-b2blag-ixc:8443

run-otgen:
#	sleep 5 # pause for all components to initialize
	otgen run --insecure --file otg.yaml --yaml --metrics flow | otgen transform --metrics flow | otgen display -m table
	otgen run --insecure --file otg.yaml --yaml --metrics port | otgen transform --metrics port | otgen display -m table
