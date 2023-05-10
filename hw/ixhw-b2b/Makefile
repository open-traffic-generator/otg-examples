SHELL = /bin/bash

.PHONY: all
all: install deploy run

.PHONY: clean
clean: remove-lab

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
	bash -c "$$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.5.0-rc1

install-clean:
	-sudo rm -f `command -v docker-compose`
	-sudo rm -f `command -v otgen`

###############################
# Deploy lab
###############################

.PHONY: deploy
deploy: deploy-lab

deploy-lab:
	sudo docker-compose up -d

remove-lab:
	sudo docker-compose down

###############################
# Run tests
###############################

.PHONY: run
run: otgen-run-as-table-port #otgen-run-as-table-flow otgen-run-as-table-flow-bytes

otgen-run-as-table-port:
	cat otg.yml | envsubst | otgen run -k -a https://localhost:8443 | otgen transform -m port | otgen display -m table

otgen-run-as-table-flow:
	cat otg.yml | envsubst | otgen run -k -a https://localhost:8443 -m flow | otgen transform -m flow | otgen display -m table

otgen-run-as-table-flow-bytes:
	cat otg.yml | envsubst | otgen run -k -a https://localhost:8443 -m flow | otgen transform -m flow -c bytes | otgen display -m table
