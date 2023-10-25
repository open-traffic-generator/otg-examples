# KENG three back-to-back pairs setup with Docker Compose

## Overview
This lab is an extension of [Ixia-c back-to-back](README.md) traffic engine setup. [Community Edition](../../KENG.md) of Ixia-c supports up to 4 traffic engine ports. If the number of ports you need exceeds four, a commercial subscription to Ixia-c should be used. In this example, the testbed has 3 pairs of Ixia-c ports, and thus requires a valid license to work.

![Diagram](./diagram.png)

## Prerequisites

* Linux host or VM with sudo permissions and Docker support
* [Docker](https://docs.docker.com/engine/install/)

## Install components

1. Install `docker-compose`

    ```Shell
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ```

2. Install `otgen`

    ```Shell
    bash -c "$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.6.2
    ```

3. Make sure `/usr/local/bin` is in your `$PATH` variable (by default this is not the case on CentOS 7)

    ```Shell
    cmd=docker-compose
    dir=/usr/local/bin
    if ! command -v ${cmd} &> /dev/null && [ -x ${dir}/${cmd} ]; then
      echo "${cmd} exists in ${dir} but not in the PATH, updating PATH to:"
      PATH="/usr/local/bin:${PATH}"
      echo $PATH
    fi
    ```

4. Clone this repository

    ```Shell
    git clone --recursive https://github.com/open-traffic-generator/otg-examples.git
    ```

## Deploy lab

1. Create 3 veth pairs

    ```Shell
    sudo ip link add name veth0 type veth peer name veth1
    sudo ip link set dev veth0 up
    sudo ip link set dev veth1 up
    sudo sysctl net.ipv6.conf.veth0.disable_ipv6=1
    sudo sysctl net.ipv6.conf.veth1.disable_ipv6=1

    sudo ip link add name veth2 type veth peer name veth3
    sudo ip link set dev veth2 up
    sudo ip link set dev veth3 up
    sudo sysctl net.ipv6.conf.veth2.disable_ipv6=1
    sudo sysctl net.ipv6.conf.veth3.disable_ipv6=1

    sudo ip link add name veth4 type veth peer name veth5
    sudo ip link set dev veth4 up
    sudo ip link set dev veth5 up
    sudo sysctl net.ipv6.conf.veth4.disable_ipv6=1
    sudo sysctl net.ipv6.conf.veth5.disable_ipv6=1
    ```

2. Launch the deployment and adjust MTUs on the veth pair

    ```Shell
    cd otg-examples/docker-compose/b2b-3pair
    sudo -E docker-compose up -d
    sudo ip link set veth0 mtu 9500
    sudo ip link set veth1 mtu 9500
    sudo ip link set veth2 mtu 9500
    sudo ip link set veth3 mtu 9500
    sudo ip link set veth4 mtu 9500
    sudo ip link set veth5 mtu 9500
    ```

3. Make sure you have all seven containers (six Ixia-c Traffic Engine + one KENG Controller) running:

    ```Shell
    sudo docker ps
    ```

    The result should look like this

    ```Shell
    CONTAINER ID   IMAGE                                                           COMMAND                  CREATED         STATUS         PORTS     NAMES
    c28385dc0225   ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85   "./entrypoint.sh"        3 seconds ago   Up 2 seconds             b2b-3pair_traffic_engine_1_1
    5c46871913bb   ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85   "./entrypoint.sh"        3 seconds ago   Up 2 seconds             b2b-3pair_traffic_engine_4_1
    c22280a15ae5   ghcr.io/open-traffic-generator/keng-controller:0.1.0-3          "./bin/controller --…"   3 seconds ago   Up 2 seconds             b2b-3pair_controller_1
    0297de3fbe49   ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85   "./entrypoint.sh"        3 seconds ago   Up 2 seconds             b2b-3pair_traffic_engine_2_1
    bc533d7cc650   ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85   "./entrypoint.sh"        3 seconds ago   Up 2 seconds             b2b-3pair_traffic_engine_3_1
    412896aca3a8   ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85   "./entrypoint.sh"        3 seconds ago   Up 2 seconds             b2b-3pair_traffic_engine_5_1
    1f82918b1f13   ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85   "./entrypoint.sh"        3 seconds ago   Up 2 seconds             b2b-3pair_traffic_engine_6_1
    ```

## Run OTG traffic flows

1. Start with running traffic flows only between two pairs of ports using `otg.2pairs.yml` configuration. This is within the limits of Community Edition and should work:

    ```Shell
    otgen run -k -f otg.2pairs.yml -m flow | otgen transform -m flow | otgen display -m table
    ```

2. Now run traffic flows defined in `otg.3pairs.yml`, which has 6 ports in total. Without a license, the following error message will be returned: `ERRO[0000] the configuration has 6 port(s) of type Ixia-c, maximum 4 ports of type Ixia-c is supported in community edition`

    ```Shell
    otgen run -k -f otg.3pairs.yml | otgen transform -m flow | otgen display -m table
    ```

## Destroy the lab

To destroy the lab, including veth pair, use:

```Shell
sudo docker-compose down
sudo ip link del name veth0 type veth peer name veth1
sudo ip link del name veth2 type veth peer name veth3
sudo ip link del name veth4 type veth peer name veth5
```
