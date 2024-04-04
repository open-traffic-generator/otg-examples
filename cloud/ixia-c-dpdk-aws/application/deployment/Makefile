.PHONY: dpdk
dpdk:
	chmod +x /home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/deployment/*.sh
	/home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/deployment/setup_dpdk.sh
	
.PHONY: docker-compose
docker-compose:
	sudo -H -u ubuntu bash -c 'docker-compose -f /home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/deployment/docker-compose.yaml up -d'
	sudo -H -u ubuntu bash -c 'docker-compose -f /home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/deployment/docker-compose.yaml ps'