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
install: install-docker-compose install-otgen install-snappi

install-docker-compose: /usr/local/bin/docker-compose
/usr/local/bin/docker-compose:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

install-otgen: /usr/local/bin/otgen
/usr/local/bin/otgen:
	bash -c "$$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.5.0-rc1

install-snappi: ./venv/lib/python3.9/site-packages/snappi/snappi.py
./venv/lib/python3.9/site-packages/snappi/snappi.py:
	python3.9 -m venv venv && \
	source venv/bin/activate && \
	pip install -r requirements.txt

install-clean:
	-sudo rm -f `command -v docker-compose`
	-sudo rm -f `command -v otgen`
	-sudo rm -rf venv

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
	-sudo ip link del name veth0 type veth peer name veth1

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-lab

deploy-lab:
	sudo docker-compose up -d
	sleep 3

remove-lab:
	sudo docker-compose down

###############################
# Run tests
###############################

.PHONY: run
run: network-mtu otgen-run-as-table-port otgen-run-as-table-flow otgen-run-as-table-flow-bytes snappi-run

otgen-run:
	cat otg.yml | otgen run -k -a https://localhost:8443

otgen-run-as-table-port:
	@echo "cat otg.yml | otgen run -k -a https://localhost:8443 | otgen transform -f ../../submodules/otgen/templates/transformPortFramesTable.tmpl"
	@echo "│Port│  FramesTx │  FramesRx │Port│  FramesTx │  FramesRx │"
	@cat otg.yml | otgen run -k -a https://localhost:8443 | otgen transform -f ../../submodules/otgen/templates/transformPortFramesTable.tmpl

otgen-run-as-table-flow:
	@echo "cat otg.yml | otgen run -k -a https://localhost:8443 -m flow | otgen transform -f ../../submodules/otgen/templates/transformFlowFramesTable.tmpl"
	@echo "│ Flow  │  FramesTx │  FramesRx │"
	@cat otg.yml | otgen run -k -a https://localhost:8443 -m flow | otgen transform -f ../../submodules/otgen/templates/transformFlowFramesTable.tmpl

otgen-run-as-table-flow-bytes:
	@echo "cat otg.yml | otgen run -k -a https://localhost:8443 -m flow | otgen transform -f ../../submodules/otgen/templates/transformFlowBytesTable.tmpl"
	@echo "│ Flow  │   BytesTx │   BytesRx │"
	@cat otg.yml | otgen run -k -a https://localhost:8443 -m flow | otgen transform -f ../../submodules/otgen/templates/transformFlowBytesTable.tmpl

snappi-run:
	source venv/bin/activate && \
	./snappi/otg-flows.py -m port