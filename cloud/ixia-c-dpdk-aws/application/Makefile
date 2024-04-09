SHELL = /bin/bash

GitRepoExecPath = "/home/ubuntu/keng-python/cloud/ixia-c-dpdk-aws/application/"

###############################
# Run tests
###############################

.PHONY: run
run: run-rfc2544

run-rfc2544:
	chmod +x $(GitRepoExecPath)/*.sh
	docker run --rm -t --net host -v $(GitRepoExecPath):/snappi --name snappi snappi:local bash -c "./rfc2544_test_n_flows.sh -s 9000"