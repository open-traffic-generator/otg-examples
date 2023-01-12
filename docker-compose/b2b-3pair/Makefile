SHELL = /bin/bash

.PHONY: all
all: install pull deploy run

.PHONY: clean
clean: lab-clean network-clean

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
	curl -L "https://github.com/open-traffic-generator/otgen/releases/download/v0.3.0/otgen_0.3.0_$$(uname -s)_$$(uname -m).tar.gz" | tar xzv otgen
	sudo mv otgen /usr/local/bin/otgen
	sudo chmod +x /usr/local/bin/otgen

install-clean:
	-sudo rm -f `command -v docker-compose`
	-sudo rm -f `command -v otgen`

###############################
# Pull images
###############################

.PHONY: pull
pull: pull-public pull-private

pull-public:
	sudo -E docker-compose pull traffic_engine_1
	
pull-private:
	sudo -E docker-compose pull controller

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-net deploy-lab 

deploy-net:veth0 veth2 veth4

veth0: /sys/class/net/veth0
/sys/class/net/veth0:
	sudo ip link add name veth0 type veth peer name veth1
	sudo ip link set dev veth0 up
	sudo ip link set dev veth1 up
	sudo sysctl net.ipv6.conf.veth0.disable_ipv6=1
	sudo sysctl net.ipv6.conf.veth1.disable_ipv6=1

veth2: /sys/class/net/veth2
/sys/class/net/veth2:
	sudo ip link add name veth2 type veth peer name veth3
	sudo ip link set dev veth2 up
	sudo ip link set dev veth3 up
	sudo sysctl net.ipv6.conf.veth2.disable_ipv6=1
	sudo sysctl net.ipv6.conf.veth3.disable_ipv6=1

veth4: /sys/class/net/veth4
/sys/class/net/veth4:
	sudo ip link add name veth4 type veth peer name veth5
	sudo ip link set dev veth4 up
	sudo ip link set dev veth5 up
	sudo sysctl net.ipv6.conf.veth4.disable_ipv6=1
	sudo sysctl net.ipv6.conf.veth5.disable_ipv6=1


deploy-lab:
	sudo docker-compose up -d
	sudo ip link set veth0 mtu 9500
	sudo ip link set veth1 mtu 9500
	sudo ip link set veth2 mtu 9500
	sudo ip link set veth3 mtu 9500
	sudo ip link set veth4 mtu 9500
	sudo ip link set veth5 mtu 9500

deploy: deploy-net deploy-lab 

lab-clean:
	sudo docker-compose down

network-clean: veth0-clean veth2-clean veth4-clean
veth0-clean:
#TODO run only if veth0 exists
	sudo ip link del name veth0 type veth peer name veth1

veth2-clean:
#TODO run only if veth2 exists
	sudo ip link del name veth2 type veth peer name veth3
veth4-clean:
#TODO run only if veth4 exists
	sudo ip link del name veth4 type veth peer name veth5

###############################
# Run tests
###############################

.PHONY: run
run: otgen-run otgen-run-display-table-port otgen-run-display-table-port otgen-run-display-table-flow-bytes

otgen-run:
	otgen run -k -f otg.3pairs.yml

otgen-run-display-table-port:
	otgen run -k -f otg.3pairs.yml | otgen transform -m port | otgen display -m table

otgen-run-display-table-flow:
	otgen run -k -f otg.3pairs.yml | otgen transform -m flow | otgen display -m table

otgen-run-display-table-flow-bytes:
	otgen run -k -f otg.3pairs.yml -m flow | otgen transform -m flow -c bytes | otgen display -m table