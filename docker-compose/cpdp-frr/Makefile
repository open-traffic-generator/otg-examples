SHELL = /bin/bash

.PHONY: all
all: install deploy run

.PHONY: all-clab
all-clab: install deploy-clab run-otgen

.PHONY: clean
clean: remove-lab remove-clab

.PHONY: clean-all
clean-all: clean install-clean

###############################
# Install components
###############################

.PHONY: install
install: install-docker-compose install-clab install-otgen

install-docker-compose: /usr/local/bin/docker-compose
/usr/local/bin/docker-compose:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

install-clab: /usr/bin/containerlab
/usr/bin/containerlab:
	bash -c "$$(curl -sL https://get.containerlab.dev)" -- -v 0.46.2

install-otgen: /usr/local/bin/otgen
/usr/local/bin/otgen:
	bash -c "$$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.6.2

install-clean:
	-sudo rm -f `command -v docker-compose`
	-sudo rm -f `command -v otgen`
	-sudo apt remove containerlab -y

###############################
# Pull images
###############################

.PHONY: pull
pull: pull-private

pull-public:
	sudo -E docker-compose pull traffic_engine_1
	sudo -E docker-compose pull frr

pull-private:
	sudo -E docker-compose pull controller protocol_engine_1

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-lab deploy-net

deploy-lab:
	sudo -E docker-compose up -d

deploy-net:
	sudo /bin/bash ../../utils/connect_containers_veth.sh cpdp-frr_traffic_engine_1_1 cpdp-frr_frr_1 veth0 veth1
	sudo /bin/bash ../../utils/connect_containers_veth.sh cpdp-frr_traffic_engine_2_1 cpdp-frr_frr_1 veth2 veth3

deploy-clab:
	sudo -E containerlab deploy --reconfigure

remove-lab:
	-sudo docker-compose down

remove-clab:
	-sudo containerlab destroy --cleanup

###############################
# Run tests
###############################

.PHONY: run
run: otg-set-config otg-start-protocols otg-fetch-arp otg-fetch-bgp otg-trasmit otg-metrics-flow otg-metrics-port

OTG_HOST=https://localhost:8443

otg-set-config:
	@echo "############################################"
	@echo "# Apply OTG configuration"
	@echo
	sleep 5 # pause for keng-controller to detect newly created interfaces
	curl -sk "$(OTG_HOST)/config" \
		-H "Content-Type: application/json" \
		-d @otg.json | tee curl.out
	@echo
	cat curl.out | jq -e "if (.errors | length) > 0 then false else true end"

otg-start-protocols:
	@echo "############################################"
	@echo "# Start protocols"
	@echo
	curl -sk "$(OTG_HOST)/control/state" \
		-H  "Content-Type: application/json" \
		-d '{"choice": "protocol","protocol": {"choice": "all","all": {"state": "start"}}}' | tee curl.out
	@echo
	cat curl.out | jq -e "if (.errors | length) > 0 then false else true end"

otg-fetch-arp:
	@echo "############################################"
	@echo "# Fetch ARP table"
	@echo
	sleep 2 # pause for ARP to complete
	curl -sk "$(OTG_HOST)/monitor/states" \
		-X POST \
		-H  'Content-Type: application/json' \
		-d '{ "choice": "ipv4_neighbors" }' | tee curl.out
	@echo
	cat curl.out | jq -e "if (.ipv4_neighbors | length) == 2 then true else false end"

otg-fetch-bgp:
	@echo "############################################"
	@echo "# Fetch BGP metrics"
	@echo
	sleep 5 # pause for BGP to converge
	curl -sk "$(OTG_HOST)/monitor/metrics" \
		-X POST \
		-H  'Content-Type: application/json' \
		-d '{ "choice": "bgpv4" }' | tee curl.out
	@echo
	cat curl.out | jq -e "if (.bgpv4_metrics | length) == 2 and \
		.bgpv4_metrics[0].session_state == \"up\" and \
		.bgpv4_metrics[0].routes_received == \"2\" and \
		.bgpv4_metrics[1].session_state == \"up\" and \
		.bgpv4_metrics[1].routes_received == \"2\" \
		then true else false end"

otg-trasmit:
	@echo "############################################"
	@echo "# Start transmitting flows"
	@echo
	curl -sk "$(OTG_HOST)/control/state" \
		-H  "Content-Type: application/json" \
		-d '{"choice": "traffic", "traffic": {"choice": "flow_transmit", "flow_transmit": {"state": "start"}}}' | tee curl.out
	@echo
	cat curl.out | jq -e "if (.errors | length) > 0 then false else true end"

otg-metrics-flow:
	@echo "############################################"
	@echo "# Fetch flow metrics"
	@echo
	sleep 10 # pause for traffic to finish
	curl -sk "$(OTG_HOST)/monitor/metrics" \
		-X POST \
		-H  'Content-Type: application/json' \
		-d '{ "choice": "flow" }' | tee curl.out
	@echo
	cat curl.out | jq -e "if (.flow_metrics | length) == 1 and \
		.flow_metrics[0].transmit == \"stopped\" and \
		.flow_metrics[0].frames_tx != \"0\" and \
		.flow_metrics[0].frames_tx == .flow_metrics[0].frames_rx \
		then true else false end"

otg-metrics-port:
	@echo "############################################"
	@echo "# Fetch port metrics"
	@echo
	curl -sk "$(OTG_HOST)/monitor/metrics" \
		-X POST \
		-H  'Content-Type: application/json' \
		-d '{ "choice": "port" }' | tee curl.out
	@echo
	cat curl.out | jq -e "if (.port_metrics | length) == 2 \
		then true else false end"

.PHONY: run-otgen

export OTG_API=https://localhost:8443

run-otgen:
	sleep 5 # pause for all components to initialize
	otgen --log debug run --insecure --file otg.json --json --rxbgp 2x --metrics flow | otgen transform --metrics flow
