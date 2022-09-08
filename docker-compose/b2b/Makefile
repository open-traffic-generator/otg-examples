SHELL = /bin/bash

.PHONY: all
all: install network deploy run

.PHONY: clean
clean: remove-lab network-clean

.PHONY: clean-all
clean-all: clean install-clean

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
	curl -L "https://github.com/open-traffic-generator/otgen/releases/download/v0.2.0/otgen_0.2.0_$$(uname -s)_$$(uname -m).tar.gz" | tar xzv otgen
	sudo mv otgen /usr/local/bin/otgen
	sudo chmod +x /usr/local/bin/otgen

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
	sudo sysctl net.ipv6.conf.veth0.disable_ipv6=1
	sudo sysctl net.ipv6.conf.veth1.disable_ipv6=1

network-mtu:
	sudo ip link set veth0 mtu 9500
	sudo ip link set veth1 mtu 9500

network-clean: veth0-clean
veth0-clean:
#TODO run only if veth0 exists
	sudo ip link del name veth0 type veth peer name veth1

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-lab

deploy-lab:
	sudo docker-compose -f ixia-c-b2b.yml up -d 

remove-lab:
	docker-compose -f ixia-c-b2b.yml down

###############################
# Run tests
###############################

.PHONY: run
run: network-mtu otgen-run otgen-run-as-table-port otgen-run-as-table-flow otgen-run-as-table-flow-bytes

otgen-run:
	cat otg.yml | otgen run -k

otgen-run-as-table-port:
	cat otg.yml | otgen run -k 2>/dev/null | otgen transform -m port | otgen display -m table

otgen-run-as-table-flow:
	cat otg.yml | otgen run -k -m flow 2>/dev/null | otgen transform -m flow | otgen display -m table

otgen-run-as-table-flow-bytes:
	cat otg.yml | otgen run -k -m flow 2>/dev/null | otgen transform -m flow -c bytes | otgen display -m table