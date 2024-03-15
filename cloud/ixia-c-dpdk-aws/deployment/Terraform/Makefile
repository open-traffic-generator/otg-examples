deploy: init apply SshKey

init:
	terraform init

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

ssh-agent1:
	terraform output SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" > SshKey.pem
	export Agent1DnsName=$$(terraform output -json Agent1Eth0ElasticIp | jq -r .public_dns)
	echo $$Agent1DnsName
	chmod 400 SshKey.pem
	ssh -i SshKey.pem ubuntu@$$Agent1DnsName

ssh-agent2:
	terraform output SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" > SshKey.pem
	export Agent2DnsName=$$(terraform output -json Agent2Eth0ElasticIp | jq -r .public_dns)
	echo $$Agent2DnsName
	chmod 400 SshKey.pem
	ssh -i SshKey.pem ubuntu@$$Agent2DnsName