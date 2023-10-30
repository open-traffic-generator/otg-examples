SHELL = /bin/bash

.PHONY: all
all: build deploy run

.PHONY: clean
clean: remove-lab

.PHONY: clean-all
clean-all: clean build-clean

###############################
# Build components
###############################

.PHONY: build
build: build-snappi

build-snappi:
ifeq ($(shell docker images -q snappi:local 2> /dev/null),)
	sudo docker build -t snappi:local snappi
endif

build-clean:
ifneq ($(shell docker images -q snappi:local 2> /dev/null),)
	docker rmi `docker images -q snappi:local 2> /dev/null` --force
endif

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-lab deploy-net

deploy-lab:
	sudo -E docker compose up -d

deploy-net:
	sudo /bin/bash ../../utils/connect_containers_veth.sh cpdp-b2b-traffic_engine_1-1 cpdp-b2b-traffic_engine_2-1 veth0 veth1

remove-lab:
	sudo docker compose down

###############################
# Run tests
###############################

.PHONY: run
run: prerun snappi-run

# pause for keng-controller to detect newly created interfaces
prerun:
	sleep 5
	sudo docker ps

snappi-run:
	sudo docker run --rm -t --net host -v $$(pwd)/snappi:/snappi -v $$(pwd)/test-config.yaml:/snappi/test-config.yaml --name snappi snappi:local  bash -c "python otg_bgp_b2b.py"

gotest-run:
	cd tests; go test -run TestIPv4BGPRouteInstall
