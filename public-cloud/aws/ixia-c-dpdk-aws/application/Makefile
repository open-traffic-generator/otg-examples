SHELL = /bin/bash

GitRepoExecPath = "/home/ubuntu/keng-python/snappi/data-plane-performance"

###############################
# Run tests
###############################

.PHONY: run
run: run-rfc2544

run-rfc2544:
	chmod +x $(GitRepoExecPath)/*.sh
	docker run --rm -t --net host -v $(GitRepoExecPath):/snappi --name snappi snappi:local bash -c "./rfc2544.sh -s 9000"