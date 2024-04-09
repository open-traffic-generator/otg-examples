###############################
# Infrastructure deployment
###############################

.PHONY: aws
aws:
	$(MAKE) -C ./deployment/Terraform all

.PHONY: clean
clean:
	$(MAKE) -C ./deployment/Terraform clean

.PHONY: run
run:
	$(MAKE) -C ./application run