SHELL = /bin/bash

.PHONY: all
all: install pull deploy run

.PHONY: clean
clean: remove-clab remove-net

.PHONY: clean-all
clean-all: clean pull-clean install-clean

###############################
# Install components
###############################

.PHONY: install
install: install-clab install-otgen

install-clab: /usr/bin/containerlab
/usr/bin/containerlab:
	bash -c "$$(curl -sL https://get.containerlab.dev)"

install-otgen: /usr/local/bin/otgen
/usr/local/bin/otgen:
	curl -L "https://github.com/open-traffic-generator/otgen/releases/download/v0.4.0-rc1/otgen_0.4.0-rc1_$$(uname -s)_$$(uname -m).tar.gz" | tar xzv otgen
	sudo mv otgen /usr/local/bin/otgen
	sudo chmod +x /usr/local/bin/otgen

install-clean:
	-sudo rm -f `command -v otgen`
	-sudo apt remove containerlab -y

###############################
# Pull images
###############################

.PHONY: pull

pull: pull-ceos

pull-clean: remove-ceos

pull-ceos:
ifeq ($(shell docker images -q ceos:latest 2> /dev/null),)
	docker pull ghcr.io/open-traffic-generator/ceos:4.28.0F
	docker tag ghcr.io/open-traffic-generator/ceos:4.28.0F ceos:latest
endif

remove-ceos:
ifneq ($(shell docker images -q ceos:latest 2> /dev/null),)
	docker rmi `docker images -q ceos:latest 2> /dev/null` --force
endif


###############################
# Deploy lab
###############################

.PHONY: deploy
deploy:  deploy-net deploy-clab

deploy-net:
	sudo bash -c 'ip link add name ixp type bridge && ip link set dev ixp up'

deploy-clab:
	sudo -E containerlab deploy --reconfigure
	sleep 30 # pause for all components to initialize

remove-clab:
	sudo containerlab destroy --cleanup

remove-net:
	-sudo ip link delete dev ixp

###############################
# Run tests
###############################

.PHONY: run
run: run-connected run-ce

run-connected:
	@echo "#################################################################"
	@echo "# Run traffic between subnets directly connected to r1 and r2"
	@echo "#################################################################"

	otgen --log debug run --insecure --file otg.json --json --metrics flow | otgen transform --metrics flow | otgen display -m table

	@echo 

run-ce: export OTG_LOCATION_P1 = localhost:5555+localhost:50071
run-ce: export OTG_LOCATION_P2 = localhost:5556+localhost:50072
run-ce:
	@echo "#################################################################"
	@echo "# Run raffic from behind emulated CE routers downstream from r1 and r2"
	@echo "#################################################################"

	otgen create device -n ce1111 --ip 192.0.2.2 --gw 192.0.2.1 --prefix 30 -p p1 > otgen.out
	cat otgen.out | otgen add bgp -d ce1111 --asn 1111 --route 1.1.1.1/32 >> otgen.out
	cat otgen.out | otgen add device -n ce2222 --ip 203.0.113.2 --gw 203.0.113.1 --prefix 30  -p p2 >> otgen.out
	cat otgen.out | otgen add bgp -d ce2222 --asn 2222 --route 2.2.2.2/32 >> otgen.out
	cat otgen.out | otgen add flow -n f1 --tx ce1111 --rx ce2222 --dmac auto --src 1.1.1.1 --dst 2.2.2.2 --rate 100 --count 1000 --size 512 >> otgen.out
	cat otgen.out | otgen add flow -n f2 --tx ce2222 --rx ce1111 --dmac auto --dst 1.1.1.1 --src 2.2.2.2 --rate 100 --count 1000 --size 512 >> otgen.out
	cat otgen.out | otgen --log debug run --insecure --metrics flow | otgen transform --metrics flow | otgen display -m table

	-@rm otgen.out
	@echo 

