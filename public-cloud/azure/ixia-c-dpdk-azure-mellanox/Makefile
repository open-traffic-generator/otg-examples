###############################
# Infrastructure deployment
###############################

all: azure run

.PHONY: azure
azure:
	$(MAKE) -C ./deployment/Terraform all

.PHONY: clean
clean:
	$(MAKE) -C ./deployment/Terraform clean

.PHONY: run
run:
	$(MAKE) -C ./deployment/CloudShell run

.PHONY: connect
connect: connect-agent1

.PHONY: connect-agent1
connect-agent1:
	$(MAKE) -C ./deployment/CloudShell connect-agent1

.PHONY: connect-agent2
connect-agent2:
	$(MAKE) -C ./deployment/CloudShell connect-agent2

