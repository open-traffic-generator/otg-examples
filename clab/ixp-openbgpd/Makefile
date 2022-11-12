SHELL = /bin/bash

.PHONY: all
all: install pull deploy

.PHONY: clean
clean: remove-clab remove-net

.PHONY: clean-all
clean-all: clean pull-clean install-clean

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
	curl -L "https://github.com/open-traffic-generator/otgen/releases/download/v0.4.0-rc1/otgen_0.4.0-rc1_$$(uname -s)_$$(uname -m).tar.gz" | tar xzv otgen
	sudo mv otgen /usr/local/bin/otgen
	sudo chmod +x /usr/local/bin/otgen

install-clean:
	-sudo rm -f `command -v otgen`
	-sudo apt remove containerlab -y

###############################
# Pull images
###############################

.PHONY: pull

pull: pull-ceos

pull-clean: remove-ceos

pull-ceos:
ifeq ($(shell docker images -q ceos:latest 2> /dev/null),)
	docker pull ghcr.io/open-traffic-generator/ceos:4.28.0F
	docker tag ghcr.io/open-traffic-generator/ceos:4.28.0F ceos:latest
endif

remove-ceos:
ifneq ($(shell docker images -q ceos:latest 2> /dev/null),)
	docker rmi `docker images -q ceos:latest 2> /dev/null` --force
endif


###############################
# Deploy lab
###############################

.PHONY: deploy
deploy:  deploy-net deploy-clab

deploy-net:
	sudo bash -c 'ip link add name ixp type bridge && ip link set dev ixp up'

deploy-clab:
	sudo -E containerlab deploy --reconfigure

remove-clab:
	sudo containerlab destroy --cleanup

remove-net:
	-sudo ip link delete dev ixp
