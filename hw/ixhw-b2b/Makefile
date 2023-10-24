SHELL = /bin/bash

.PHONY: all
all: install deploy run logs

.PHONY: clean
clean: remove-lab

.PHONY: clean-all
clean-all: clean logs-clean install-clean

###############################
# Install components
###############################

.PHONY: install
install: install-otgen

install-otgen: /usr/local/bin/otgen
/usr/local/bin/otgen:
	bash -c "$$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.6.2

install-clean:
	-sudo rm -f `command -v otgen`

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-lab

deploy-lab:
	sudo -E docker compose up -d
	sleep 5

remove-lab:
	sudo docker compose down

###############################
# Run tests
###############################

.PHONY: run
run: otgen-run-as-table-port otgen-run-as-table-flow otgen-run-as-table-flow-bytes

otgen-run-as-table-port:
	cat otg.yml | envsubst | otgen run -k -a https://localhost:8443 | otgen transform -m port | otgen display -m table

otgen-run-as-table-flow:
	cat otg.yml | envsubst | otgen run -k -a https://localhost:8443 -m flow | otgen transform -m flow | otgen display -m table

otgen-run-as-table-flow-bytes:
	cat otg.yml | envsubst | otgen run -k -a https://localhost:8443 -m flow | otgen transform -m flow -c bytes | otgen display -m table

###############################
# Collect logs
###############################

.PHONY: logs
logs:
	../../utils/collect-ixia-c-hw-logs.sh

logs-clean:
	rm logs-*.tar.gz