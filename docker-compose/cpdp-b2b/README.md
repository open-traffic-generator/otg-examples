# KENG back-to-back setup with Docker Compose

## Overview
This is an extended version of a basic [Ixia-c back-2-back lab](../b2b/README.md) with [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) components added to emulate L2-3 protocols like BGP. In this lab, [Ixia-c](https://github.com/open-traffic-generator/ixia-c) has two traffic ports connected back-2-back using a veth pair. In addition, two protocol engines share network namespaces with respective traffic ports. The lab is defined via Docker Compose YAML file. Once the lab is up, a CLI tool [`otgen`](https://github.com/open-traffic-generator/otgen) is used to request Ixia-c to generate traffic and report statistics.

![Diagram](./diagram.png)

## Preprequisites

* Licensed [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) images
* Linux host or VM with sudo permissions and Docker support
* [Docker](https://docs.docker.com/engine/install/)
* [Go](https://go.dev/dl/)

## Install components

1. Install `docker-compose`

```Shell
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

2. Download `connect_containers_veth.sh`

```Shell
wget "https://raw.githubusercontent.com/open-traffic-generator/otg-examples/main/utils/connect_containers_veth.sh" 
chmod +x connect_containers_veth.sh
```

3. Install `otgen`

```Shell
curl -L "https://github.com/open-traffic-generator/otgen/releases/download/v0.2.0/otgen_0.2.0_$(uname -s)_$(uname -m).tar.gz" | tar xzv otgen
sudo mv otgen /usr/local/bin/otgen
sudo chmod +x /usr/local/bin/otgen
```

## Deploy Ixia-c lab

1. Create YAML file for Docker Compose

```Shell
cat > cpdp-b2b.yml << EOF
services:
  controller:
    image: ghcr.io/open-traffic-generator/licensed/ixia-c-controller:0.0.1-3002
    command: --accept-eula --http-port 443
    network_mode: "host"
    restart: always
  traffic_engine_1:
    image: ixiacom/ixia-c-traffic-engine:1.4.1.29
    restart: always
    privileged: true
    ports:
      - "5555:5555"
    environment:
    - OPT_LISTEN_PORT=5555
    - ARG_IFACE_LIST=virtual@af_packet,veth0
    - OPT_NO_HUGEPAGES=Yes
    - OPT_NO_PINNING=Yes
    - WAIT_FOR_IFACE=Yes
  traffic_engine_2:
    image: ixiacom/ixia-c-traffic-engine:1.4.1.29
    restart: always
    privileged: true
    ports:
      - "5556:5556"
    environment:
    - OPT_LISTEN_PORT=5556
    - ARG_IFACE_LIST=virtual@af_packet,veth1
    - OPT_NO_HUGEPAGES=Yes
    - OPT_NO_PINNING=Yes
    - WAIT_FOR_IFACE=Yes
  protocol_engine_1:
    image: ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.205
    restart: always
    privileged: true
    network_mode: service:traffic_engine_1
    environment:
    - INTF_LIST=veth0
  protocol_engine_2:
    image: ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.205
    restart: always
    privileged: true
    network_mode: service:traffic_engine_2
    environment:
    - INTF_LIST=veth1
EOF
```

2. Launch the deployment

```Shell
sudo docker-compose -f cpdp-b2b.yml up -d 
sudo docker ps
````

3. Make sure you have all five containers running. The result should look like this
  
```Shell
CONTAINER ID   IMAGE                                                                       COMMAND                  CREATED              STATUS              PORTS                                                                                      NAMES
cae49d871bc9   ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.205   "/docker_im/opt/Ixia…"   4 seconds ago        Up 3 seconds                                                                                                   cpdp-b2b_protocol_engine_1_1
82e89b618e66   ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.205   "/docker_im/opt/Ixia…"   4 seconds ago        Up 3 seconds                                                                                                   cpdp-b2b_protocol_engine_2_1
7ed141bf8f41   ixiacom/ixia-c-traffic-engine:1.4.1.29                                      "./entrypoint.sh"        5 seconds ago        Up 3 seconds        0.0.0.0:5556->5556/tcp, :::5556->5556/tcp, 0.0.0.0:50072->50071/tcp, :::50072->50071/tcp   cpdp-b2b_traffic_engine_2_1
ee375ede5bbe   ixiacom/ixia-c-traffic-engine:1.4.1.29                                      "./entrypoint.sh"        5 seconds ago        Up 3 seconds        0.0.0.0:5555->5555/tcp, :::5555->5555/tcp, 0.0.0.0:50071->50071/tcp, :::50071->50071/tcp   cpdp-b2b_traffic_engine_1_1
0e3436e30680   ghcr.io/open-traffic-generator/licensed/ixia-c-controller:0.0.1-3002        "./bin/controller --…"   About a minute ago   Up About a minute                                                                                              cpdp-b2b_controller_1
```

4. Interconnect traffic engine containers via a veth pair

```Shell
sudo ./connect_containers_veth.sh cpdp-b2b_traffic_engine_1_1 cpdp-b2b_traffic_engine_2_1 veth0 veth1
````

5. Check traffic and protocol engine logs to see if they picked up veth interfaces

```Shell
sudo docker logs cpdp-b2b_traffic_engine_1_1
sudo docker logs cpdp-b2b_traffic_engine_2_1
sudo docker logs cpdp-b2b_protocol_engine_1_1
sudo docker logs cpdp-b2b_protocol_engine_2_1
```

## Start protocols

```Shell
cd tests
go test -run TestBGPRouteInstall
```

## Run OTG traffic flows

1. Download an example of OTG traffic flow configuration file:

```Shell
wget https://raw.githubusercontent.com/open-traffic-generator/otg-examples/docker-compose/docker-compose/b2b/otg.yml
```

1. Start with using `otgen` to request Ixia-c to run traffic flows defined in `otg.yml`. If successful, the result will come as OTG port metrics in JSON format

```Shell
cat otg.yml | otgen run -k
````

2. You can now repeat this exercise, but transform output to a table

```Shell
cat otg.yml | otgen run -k 2>/dev/null | otgen transform -m port | otgen display -m table
````

3. The same, but with flow metrics

```Shell
cat otg.yml | otgen run -k -m flow 2>/dev/null | otgen transform -m flow | otgen display -m table
````

4. The same, but with byte instead of frame count (only receive stats are reported)

```Shell
cat otg.yml | otgen run -k -m flow 2>/dev/null | otgen transform -m flow -c bytes | otgen display -m table
````

5. Now report packet per second rate, as a line chart (end with `Crtl-c`)

```Shell
cat otg.yml | otgen run -k -m flow 2>/dev/null | otgen transform -m flow -c pps | otgen display -m chart
````

## Destroy the lab

To destroy the lab, including veth pair, use:

```Shell
docker-compose -f cpdp-b2b.yml down
````

## Credits

* `connect_containers_veth.sh` copyright of [Levente Csikor](https://github.com/cslev/add_veth_to_docker/), with modifications to replace `ifconfig` with `ip link`.
