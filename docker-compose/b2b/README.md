# Basic Ixia-c back-to-back traffic engine setup with `docker-compose`

## Overview
This is a basic lab where an Ixia-c-one node has two traffic ports connected back-2-back using an veth pair. The lab is controlled via `docker-compose`. Once the lab is up, a CLI tool `otgen` is used to request Ixia-c to generate traffic and report statistics.

## Preprequisites

* Linux host or VM with sudo permissions and Docker support
* [Docker](https://docs.docker.com/engine/install/)

## Install components

1. Install `docker-compose`

```Shell
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

2. Install `otgen`

curl -L "https://github.com/open-traffic-generator/otgen/releases/download/v0.2.0/otgen_0.2.0_$(uname -s)_$(uname -m).tar.gz" | tar xzv otgen
sudo mv otgen /usr/local/bin/otgen
sudo chmod +x /usr/local/bin/otgen


## Deploy Ixia-c lab

1. Create veth pair `veth0 - veth1`

```Shell
sudo ip link add name veth0 type veth peer name veth1
sudo ip link set dev veth0 up
sudo ip link set dev veth1 up
sudo sysctl net.ipv6.conf.veth0.disable_ipv6=1
sudo sysctl net.ipv6.conf.veth1.disable_ipv6=1
```

2. Create YAML file for `docker-compose` with veth interfaces assigned to `ixia-c-traffic-engine` containers

```Shell
cat > ixia-c-b2b.yml << EOF
services:
  controller:
    image: ixiacom/ixia-c-controller:0.0.1-3002
    command: --accept-eula --http-port 443
    network_mode: "host"
    restart: always
  traffic_engine_1:
    image: ixiacom/ixia-c-traffic-engine:1.4.1.29
    network_mode: "host"
    restart: always
    privileged: true
    environment:
    - OPT_LISTEN_PORT=5555
    - ARG_IFACE_LIST=virtual@af_packet,veth0
    - OPT_NO_HUGEPAGES=Yes
  traffic_engine_2:
    image: ixiacom/ixia-c-traffic-engine:1.4.1.29
    network_mode: "host"
    restart: always
    privileged: true
    environment:
    - OPT_LISTEN_PORT=5556
    - ARG_IFACE_LIST=virtual@af_packet,veth1
    - OPT_NO_HUGEPAGES=Yes
EOF
```

3. Launch the deployment and adjust MTUs on the veth pair

```Shell
docker-compose -f ixia-c-b2b.yml up -d 
sudo ip link set veth0 mtu 9500
sudo ip link set veth1 mtu 9500
````

4. Make sure you have all three containers running:

```Shell
docker ps
```

  The result should look like this
  
```Shell
CONTAINER ID   IMAGE                                    COMMAND                  CREATED          STATUS          PORTS     NAMES
4b1e929d8153   ixiacom/ixia-c-traffic-engine:1.4.1.29   "./entrypoint.sh"        29 seconds ago   Up 27 seconds             b2b_traffic_engine_2_1
1943f3a25849   ixiacom/ixia-c-traffic-engine:1.4.1.29   "./entrypoint.sh"        29 seconds ago   Up 27 seconds             b2b_traffic_engine_1_1
d3497ae9470e   ixiacom/ixia-c-controller:0.0.1-3002     "./bin/controller --…"   29 seconds ago   Up 27 seconds             b2b_controller_1
```

## Run OTG traffic flows

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
docker-compose -f ixia-c-b2b.yml down
sudo ip link del name veth0 type veth peer name veth1
````

## Credits

* [Diana Galan](https://github.com/dgalan-xxia) for `docker-compose` example.
