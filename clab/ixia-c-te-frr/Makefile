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
	bash -c "$$(curl -sL https://get.containerlab.dev)"

install-otgen: /usr/local/bin/otgen
/usr/local/bin/otgen:
	curl -L "https://github.com/open-traffic-generator/otgen/releases/download/v0.4.0/otgen_0.4.0_$$(uname -s)_$$(uname -m).tar.gz" | tar xzv otgen
	sudo mv otgen /usr/local/bin/otgen
	sudo chmod +x /usr/local/bin/otgen

install-clean:
	-sudo rm -f `command -v otgen`
	-sudo apt remove containerlab -y

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-clab

deploy-clab:
	sudo containerlab deploy -t topo.clab.yml --reconfigure

deploy-clab-3768:
	sudo containerlab deploy -t topo-0.0.1-3768.clab.yml --reconfigure

remove-clab:
	sudo containerlab destroy -t topo.clab.yml --cleanup

remove-clab-3768:
	sudo containerlab destroy -t topo-0.0.1-3768.clab.yml --cleanup

###############################
# Run tests
###############################

.PHONY: run
run: run-otgen

export OTG_API=https://localhost:8443

.PHONY: run-otgen
run-otgen:
	TE1SMAC=$$(cat clab-ixctedut/topology-data.json | jq -r '.links[0]["a"].mac'); \
	TE1DMAC=$$(cat clab-ixctedut/topology-data.json | jq -r '.links[0]["z"].mac'); \
	TE2SMAC=$$(cat clab-ixctedut/topology-data.json | jq -r '.links[1]["a"].mac'); \
	TE2DMAC=$$(cat clab-ixctedut/topology-data.json | jq -r '.links[1]["z"].mac'); \
	cat otg.yml | \
	sed "s/00:00:00:00:11:aa/$${TE1SMAC}/g" | sed "s/00:00:00:00:11:bb/$${TE1DMAC}/g" | \
	sed "s/00:00:00:00:22:aa/$${TE2SMAC}/g" | sed "s/00:00:00:00:22:bb/$${TE2DMAC}/g" | \
	otgen run -k | \
	otgen transform -m port | \
	otgen display -m table

run-d2d:
	export OTG_FLOW_SMAC_P1=$$(cat clab-ixctedut/topology-data.json | jq -r '.links[0]["a"].mac'); \
	export OTG_FLOW_DMAC_P1=$$(cat clab-ixctedut/topology-data.json | jq -r '.links[0]["z"].mac'); \
	export OTG_FLOW_SMAC_P2=$$(cat clab-ixctedut/topology-data.json | jq -r '.links[1]["a"].mac'); \
	export OTG_FLOW_DMAC_P2=$$(cat clab-ixctedut/topology-data.json | jq -r '.links[1]["z"].mac'); \
	otgen create flow -s 192.0.2.1 -d 192.0.2.5 -p 80 --rate 100 --count 1000 --size 512 --txl te1:5555 --rxl te2:5555 | \
	otgen run -k | \
	otgen transform -m port | \
	otgen display -m table
