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
install: install-docker-compose install-otgen

install-docker-compose: /usr/local/bin/docker-compose
/usr/local/bin/docker-compose:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

install-otgen: /usr/local/bin/otgen
/usr/local/bin/otgen:
	bash -c "$$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.4.2

install-clean:
	-sudo rm -f `command -v docker-compose`
	-sudo rm -f `command -v otgen`

###############################
# Pull images
###############################

.PHONY: pull
pull: pull-private

pull-private:
	sudo -E docker-compose pull ixia-c-ixhw-server

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