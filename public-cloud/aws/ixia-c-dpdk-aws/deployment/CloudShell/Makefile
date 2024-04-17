###############################
# Run Application
###############################

.PHONY: run
run:
	chmod +x *.sh
	./run.sh -i $$(terraform output -state ../Terraform/terraform.tfstate -json Agent1Eth0ElasticIp | jq -r .public_ip)

.PHONY: connect
connect: connect-agent1

connect-agent1:
	chmod +x *.sh
	./connect.sh -i $$(terraform output -state ../Terraform/terraform.tfstate -json Agent1Eth0ElasticIp | jq -r .public_ip)

connect-agent2:
	chmod +x *.sh
	./connect.sh -i $$(terraform output -state ../Terraform/terraform.tfstate -json Agent2Eth0ElasticIp | jq -r .public_ip)	