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
