###############################
# Infrastructure deployment
###############################

all: aws run

.PHONY: aws
aws:
	$(MAKE) -C ./deployment/Terraform all

.PHONY: clean
clean:
	$(MAKE) -C ./deployment/Terraform clean

.PHONY: run
run:
	$(MAKE) -C ./deployment/CloudShell run

.PHONY: connect
connect:
	$(MAKE) -C ./deployment/CloudShell connect

.PHONY: connect-agent2
connect-agent2:
	$(MAKE) -C ./deployment/CloudShell connect-agent2

