###############################
# Run Application
###############################

.PHONY: run
run:
	chmod +x run.sh
	./run.sh -i $$(terraform output -state ../Terraform/terraform.tfstate -json Agent1Eth0ElasticIp | jq -r .public_ip)

connect-agent1:
	chmod +x connect.sh
	./connect.sh -i $$(terraform output -state ../Terraform/terraform.tfstate -json Agent1Eth0ElasticIp | jq -r .public_ip)

connect-agent2:
	chmod +x connect.sh
	./connect.sh -i $$(terraform output -state ../Terraform/terraform.tfstate -json Agent2Eth0ElasticIp | jq -r .public_ip)	