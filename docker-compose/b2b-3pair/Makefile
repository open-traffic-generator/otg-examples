SHELL = /bin/bash

.PHONY: all
all: install deploy run

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
	bash -c "$$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.6.2

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
	sudo -E docker-compose up -d
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
run: otgen-run-2pairs otgen-run-3pairs

otgen-run-2pairs:
	otgen run -k -f otg.2pairs.yml -m flow | otgen transform -m flow | otgen display -m table

otgen-run-3pairs:
	otgen run -k -f otg.3pairs.yml -m flow && /bin/false || /bin/true
