# FRR as a DUT with BGP and traffic setup with Docker Compose

## Overview
TODO 

## Prerequisites

* Licensed [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) images. Read more in [KENG.md](/KENG.md)
* Linux host or VM with sudo permissions and Docker support
* [Docker](https://docs.docker.com/engine/install/)
* [Go](https://go.dev/dl/)

## Install components

1. Install `docker-compose` and add yourself to `docker` group. Logout for group changes to take effect

```Shell
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo usermod -aG docker $USER
logout
```

2. Make sure `/usr/local/bin` is in your `$PATH` variable (by default this is not the case on CentOS 7)

```Shell
cmd=docker-compose
dir=/usr/local/bin
if ! command -v ${cmd} &> /dev/null && [ -x ${dir}/${cmd} ]; then
  echo "${cmd} exists in ${dir} but not in the PATH, updating PATH to:"
  PATH="/usr/local/bin:${PATH}"
  echo $PATH
fi
```

3. Clone this repository

```Shell
git clone https://github.com/open-traffic-generator/otg-examples.git
```

## Deploy Ixia-c lab

1. Launch the deployment

```Shell
cd otg-examples/docker-compose/cpdp-frr
docker-compose up -d 
sudo docker ps
```

2. Make sure you have all five containers running. The result should look like this
  
```Shell
CONTAINER ID   IMAGE                                                                       COMMAND                  CREATED              STATUS              PORTS                                                                                      NAMES
22c439d4f632   ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.236   "/docker_im/opt/Ixia…"   About a minute ago   Up About a minute                                                                                              cpdp-frr_protocol_engine_1_1
3d4bc47b027d   ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.236   "/docker_im/opt/Ixia…"   About a minute ago   Up About a minute                                                                                              cpdp-frr_protocol_engine_2_1
11314fa39cd1   frrouting/frr:v8.2.2                                                        "/sbin/tini -- /usr/…"   About a minute ago   Up About a minute                                                                                              cpdp-frr_frr_1
4ede5943c0b5   ghcr.io/open-traffic-generator/licensed/ixia-c-controller:0.0.1-3587        "./bin/controller --…"   About a minute ago   Up About a minute                                                                                              cpdp-frr_controller_1
3e31f665741c   ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.19               "./entrypoint.sh"        About a minute ago   Up About a minute   0.0.0.0:5556->5556/tcp, :::5556->5556/tcp, 0.0.0.0:50072->50071/tcp, :::50072->50071/tcp   cpdp-frr_traffic_engine_2_1
b0dcff8f14be   ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.19               "./entrypoint.sh"        About a minute ago   Up About a minute   0.0.0.0:5555->5555/tcp, :::5555->5555/tcp, 0.0.0.0:50071->50071/tcp, :::50071->50071/tcp   cpdp-frr_traffic_engine_1_1
```

3. Interconnect traffic engine containers via a veth pair

```Shell
sudo ../../utils/connect_containers_veth.sh cpdp-frr_traffic_engine_1_1 cpdp-frr_frr_1 veth0 veth1
sudo ../../utils/connect_containers_veth.sh cpdp-frr_traffic_engine_2_1 cpdp-frr_frr_1 veth2 veth3
````

4. Check traffic and protocol engine logs to see if they picked up veth interfaces

```Shell
sudo docker logs cpdp-frr_traffic_engine_1_1
sudo docker logs cpdp-frr_traffic_engine_2_1
sudo docker logs cpdp-frr_protocol_engine_1_1
sudo docker logs cpdp-frr_protocol_engine_2_1
```

## Run tests

1. Apply config

```Shell
OTG_HOST="https://localhost"
curl -k "${OTG_HOST}/config" \
    -H "Content-Type: application/json" \
    -d @otg.json
```

2. Start protocols

```Shell
curl -k "${OTG_HOST}/control/protocols" \
    -H  "Content-Type: application/json" \
    -d '{"state": "start"}'
```

3. Fetch ARP table

```Shell
curl -sk "${OTG_HOST}/results/states" \
    -X POST \
    -H  'Content-Type: application/json' \
    -d '{ "choice": "ipv4_neighbors" }'
```

4. Start transmitting flows

```Shell
curl -sk "${OTG_HOST}/control/transmit" \
    -H  "Content-Type: application/json" \
    -d '{"state": "start"}'
```

5. Fetch port metrics

```Shell
watch -n 1 "curl -sk \"${OTG_HOST}/results/metrics\" \
    -X POST \
    -H  'Content-Type: application/json' \
    -d '{ \"choice\": \"port\" }'"
```


6. Fetch flow metrics

```Shell
watch -n 1 "curl -sk \"${OTG_HOST}/results/metrics\" \
    -X POST \
    -H  'Content-Type: application/json' \
    -d '{ \"choice\": \"flow\" }'"
```


## Destroy the lab

To destroy the lab, including veth pair, use:

```Shell
docker-compose down
````

## Credits

* `connect_containers_veth.sh` copyright of [Levente Csikor](https://github.com/cslev/add_veth_to_docker/), with modifications to replace `ifconfig` with `ip link`.
