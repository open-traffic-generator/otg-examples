SHELL = /bin/bash

.PHONY: all
all: install pull deploy run

.PHONY: clean
clean: remove-lab

.PHONY: clean-all
clean-all: clean install-clean

###############################
# Install components
###############################

.PHONY: install
install: install-docker-compose

install-docker-compose: /usr/local/bin/docker-compose
/usr/local/bin/docker-compose:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	
install-clean:
	-sudo rm -f `command -v docker-compose`

###############################
# Pull images
###############################

.PHONY: pull
pull: pull-public pull-private

pull-public:
	docker-compose pull traffic_engine_1
	
pull-private:
	docker-compose pull controller protocol_engine_1

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-lab deploy-net

deploy-lab:
	sudo docker-compose up -d

deploy-net:
	sudo ../../utils/connect_containers_veth.sh cpdp-frr_traffic_engine_1_1 cpdp-frr_frr_1 veth0 veth1
	sudo ../../utils/connect_containers_veth.sh cpdp-frr_traffic_engine_2_1 cpdp-frr_frr_1 veth2 veth3

remove-lab:
	docker-compose down

###############################
# Run tests
###############################

.PHONY: run
run: otg-set-config otg-start-protocols otg-fetch-arp otg-fetch-bgp otg-trasmit otg-metrics-flow otg-metrics-port

OTG_HOST="https://localhost"

otg-set-config:
	@echo "############################################"
	@echo "# Apply OTG configuration"
	@echo
	sleep 5 # pause for ixia-c-controller to detect newly created interfaces
	curl -sk "$(OTG_HOST)/config" \
		-H "Content-Type: application/json" \
		-d @otg.json | \
	jq -e "if (.warnings | length) > 0 then false else true end"

otg-start-protocols:
	@echo "############################################"
	@echo "# Start protocols"
	@echo
	curl -sk "$(OTG_HOST)/control/protocols" \
		-H  "Content-Type: application/json" \
		-d '{"state": "start"}'
	@echo

otg-fetch-arp:
	@echo "############################################"
	@echo "# Fetch ARP table"
	@echo
	sleep 2 # pause for ARP to complete
	curl -sk "$(OTG_HOST)/results/states" \
		-X POST \
		-H  'Content-Type: application/json' \
		-d '{ "choice": "ipv4_neighbors" }'
	@echo

otg-fetch-bgp:
	@echo "############################################"
	@echo "# Fetch BGP metrics"
	@echo
	sleep 5 # pause for BGP to converge
	curl -sk "$(OTG_HOST)/results/metrics" \
		-X POST \
		-H  'Content-Type: application/json' \
		-d '{ "choice": "bgpv4" }'
	@echo

otg-trasmit:
	@echo "############################################"
	@echo "# Start transmitting flows"
	@echo
	curl -sk "$(OTG_HOST)/control/transmit" \
		-H  "Content-Type: application/json" \
		-d '{"state": "start"}'
	@echo

otg-metrics-flow:
	@echo "############################################"
	@echo "# Fetch flow metrics"
	@echo
	sleep 10 # pause for traffic to finish
	curl -sk "$(OTG_HOST)/results/metrics" \
		-X POST \
		-H  'Content-Type: application/json' \
		-d '{ "choice": "flow" }'
	@echo

otg-metrics-port:
	@echo "############################################"
	@echo "# Fetch port metrics"
	@echo
	curl -sk "$(OTG_HOST)/results/metrics" \
		-X POST \
		-H  'Content-Type: application/json' \
		-d '{ "choice": "port" }'
	@echo
