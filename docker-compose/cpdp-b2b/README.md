# KENG back-to-back BGP and traffic setup with Docker Compose

## Overview
This is an extended version of a basic [Ixia-c back-2-back lab](../b2b/README.md) with [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) components added to emulate L2-3 protocols like BGP. In this lab, [Ixia-c](https://github.com/open-traffic-generator/ixia-c) has two traffic ports connected back-2-back using a veth pair. In addition, two protocol engines share network namespaces with respective traffic ports. The lab is defined via Docker Compose YAML file. Once the lab is up, a test Go package is used to request KENG to bring up a BGP session between two ports, generate traffic and report statistics.

![Diagram](./diagram.png)

## Prerequisites

* Licensed [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) images. Read more in [KENG.md](/KENG.md)
* Linux host or VM with sudo permissions and Docker support
* [Docker](https://docs.docker.com/engine/install/)
* [Go](https://go.dev/dl/)

## Install components

1. Install `docker-compose`

```Shell
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

2. Clone this repository

```Shell
git clone https://github.com/open-traffic-generator/otg-examples.git
```

## Deploy Ixia-c lab

1. Launch the deployment

```Shell
cd otg-examples/docker-compose/cpdp-b2b
sudo docker-compose -f cpdp-b2b.yml up -d 
sudo docker ps
```

2. Make sure you have all five containers running. The result should look like this
  
```Shell
CONTAINER ID   IMAGE                                                                       COMMAND                  CREATED          STATUS         PORTS                                                                                      NAMES
4a9d84784c46   ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.205   "/docker_im/opt/Ixia…"   8 seconds ago    Up 7 seconds                                                                                              cpdp-b2b_protocol_engine_1_1
13119efaea26   ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.205   "/docker_im/opt/Ixia…"   8 seconds ago    Up 7 seconds                                                                                              cpdp-b2b_protocol_engine_2_1
0bf9781a133a   ixiacom/ixia-c-traffic-engine:1.4.1.29                                      "./entrypoint.sh"        11 seconds ago   Up 8 seconds   0.0.0.0:5556->5556/tcp, :::5556->5556/tcp, 0.0.0.0:50072->50071/tcp, :::50072->50071/tcp   cpdp-b2b_traffic_engine_2_1
1604ef2956ab   ixiacom/ixia-c-traffic-engine:1.4.1.29                                      "./entrypoint.sh"        11 seconds ago   Up 8 seconds   0.0.0.0:5555->5555/tcp, :::5555->5555/tcp, 0.0.0.0:50071->50071/tcp, :::50071->50071/tcp   cpdp-b2b_traffic_engine_1_1
45798f6d3c59   ghcr.io/open-traffic-generator/licensed/ixia-c-controller:0.0.1-3002        "./bin/controller --…"   11 seconds ago   Up 9 seconds                                                                                              cpdp-b2b_controller_1
```

3. Interconnect traffic engine containers via a veth pair

```Shell
sudo ../../utils/connect_containers_veth.sh cpdp-b2b_traffic_engine_1_1 cpdp-b2b_traffic_engine_2_1 veth0 veth1
````

4. Check traffic and protocol engine logs to see if they picked up veth interfaces

```Shell
sudo docker logs cpdp-b2b_traffic_engine_1_1
sudo docker logs cpdp-b2b_traffic_engine_2_1
sudo docker logs cpdp-b2b_protocol_engine_1_1
sudo docker logs cpdp-b2b_protocol_engine_2_1
```

## Run test package

```Shell
cd tests
go test -run TestIPv4BGPRouteInstall
cd ..
```

## Destroy the lab

To destroy the lab, including veth pair, use:

```Shell
docker-compose -f cpdp-b2b.yml down
````

## Credits

* `connect_containers_veth.sh` copyright of [Levente Csikor](https://github.com/cslev/add_veth_to_docker/), with modifications to replace `ifconfig` with `ip link`.
