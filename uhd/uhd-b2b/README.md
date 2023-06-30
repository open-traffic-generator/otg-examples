# Keysight UHD400T back-to-back setup

## Overview
TODO

## Prerequisites

* Keysight UHD400T Traffic Generator with ports 1 and 2 connected back-to-back
* Linux server directly connected to UHD400T port 32 with Ethernet cable using NIC with 10GE or higher speed
* [Docker](https://docs.docker.com/engine/install/). After installing, add yourself to `docker` group:

    ```Shell
    sudo usermod -aG docker $USER
    ```

## Install components

1. Install `docker-compose`

    ```Shell
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ```

2. Install `otgen`

    ```Shell
    bash -c "$(curl -sL https://get.otgcdn.net/otgen)"
    ```

3. Clone this repository

    ```Shell
    git clone --recursive --branch uhd400 https://github.com/open-traffic-generator/otg-examples.git
    cd otg-examples/uhd/uhd-b2b
    ```

## Deploy Ixia-c lab

1. Create virtual wiring interfaces for UHD front panel ports. In the example below, replace `eno2` with a name of the interface connected to UHD:

    ```Shell
    # name of the interface directly connected to UHD
    TRUNK=eno2
    # uhd.1
    sudo ip link add link "$TRUNK" name uhd.1 type vlan id 136
    sudo ip link set uhd.1 address "$(printf '00:60:2F:AA:0B:%02X\n' "1")"
    sudo ip link set uhd.1 up
    # uhd.2
    sudo ip link add link "$TRUNK" name uhd.2 type vlan id 144
    sudo ip link set uhd.2 address "$(printf '00:60:2F:AA:0B:%02X\n' "2")"
    sudo ip link set uhd.2 up
    ```

2. Launch the deployment and adjust MTUs on the veth pair

    ```Shell
    docker-compose up -d
    ```

3. Make sure you have all three containers running:

    ```Shell
    sudo docker ps
    ```

## Run OTG traffic flows with `otgen` tool

1. Start with using `otgen` to request Ixia-c to run traffic flows defined in `otg.yml`. If successful, the result will come as OTG port metrics in JSON format

    ```Shell
    cat otg.yml | otgen run -k -a https://localhost:8443
    ```

2. You can now repeat this exercise, but transform output to a table

    ```Shell
    cat otg.yml | otgen run -k -a https://localhost:8443 | otgen transform -m port | otgen display -m table
    ```

3. The same, but with flow metrics

    ```Shell
    cat otg.yml | otgen run -k -a https://localhost:8443 -m flow | otgen transform -m flow | otgen display -m table
    ```

4. The same, but with byte instead of frame count (only receive stats are reported)

    ```Shell
    cat otg.yml | otgen run -k -a https://localhost:8443 -m flow | otgen transform -m flow -c bytes | otgen display -m table
    ```

5. Now report packet per second rate, as a line chart (end with `Crtl-c`)

    ```Shell
    cat otg.yml | otgen run -k -a https://localhost:8443 -m flow | otgen transform -m flow -c pps | otgen display -m chart
    ```

## Destroy the lab

To destroy the lab, including veth pair, use:

```Shell
docker-compose down
sudo ip link del name uhd.1
sudo ip link del name uhd.2
```

