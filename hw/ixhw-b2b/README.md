# OTG with Ixia L23 Hardware: back-to-back setup

## Overview
This example demonstrates how the OTG API can be used to control [Keysight/Ixia L23 Network Test Hardware](https://www.keysight.com/us/en/products/network-test/network-test-hardware.html). The same [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) `ixia-c-controller` that serves as the OTG API Endpoint for [Ixia-c software test ports](https://github.com/open-traffic-generator/otg-examples/tree/main/docker-compose/cpdp-b2b) can be used with the hardware test ports. Such deployment model requires to use `ixia-c-ixhw-server` container image that provides an interface between the controller and the hardware test ports. See the diagram below that illustrates the components of such setup:

![Diagram](./diagram.png)

## Prerequisites

* Access to [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) license and images. Read more in [KENG.md](../../KENG.md)

* Keysight Ixia Novus or AresOne [Network Test Hardware](https://www.keysight.com/us/en/products/network-test/network-test-hardware.html) with [IxOS](https://support.ixiacom.com/ixos-software-downloads-documentation) 9.20 or higher

* Linux host or VM with sudo permissions and Docker support. Here is an example of deploying an Ubuntu VM `otg` using [multipass](https://multipass.run/):

    ```Shell
    multipass launch 22.04 -n otg -c4 -m8G -d32G
    multipass shell otg
    ```

* [Docker](https://docs.docker.com/engine/install/)

    ```Shell
    sudo apt update && sudo apt install docker.io -y
    ```

* Python3 (version 3.9 or higher), PIP and VirtualEnv

    ```Shell
    sudo apt install python3 python3-pip -y
    sudo pip3 install virtualenv
    ```

* `git` and `envsubst` commands (typically installed by default)

    ```Shell
    sudo apt install git gettext-base -y
    ```

## Install components

1. Install `docker-compose`

    ```Shell
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose && \
    sudo chmod +x /usr/local/bin/docker-compose
    ```

2. Install `otgen`

    ```Shell
    bash -c "$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.4.2
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
    cd otg-examples/docker-compose/b2b
    ```

## Deploy Keysight Elastic Network Generator

1. Launch the deployment

    ```Shell
    sudo -E docker-compose up -d
    ```

2. Make sure you have two containers running: `ixhw-b2b_ixia-c-controller_1` and `ixhw-b2b_ixia-c-ixhw-server_1`

    ```Shell
    sudo docker ps
    ```

3. Initialize environment variables with locations of Ixia L23 hardware ports. Replace `ixos_ip_address`, `slot_number_X`, `port_number_X` with values matching your equipment.

    ```Shell
    export OTG_LOCATION_P1="ixos_ip_address;slot_number_1;port_number_1"
    export OTG_LOCATION_P2="ixos_ip_address;slot_number_2;port_number_2"
    ```


## Run OTG traffic flows with `otgen` tool

1. Start with using `otgen` to request Ixia-c to run traffic flows defined in `otg.yml`. If successful, the result will come as OTG port metrics in table format

    ```Shell
    cat otg.yml | envsubst | otgen run -k -a https://localhost:8443 | otgen transform -m port | otgen display -m table
    ```

2. The same, but with flow metrics

    ```Shell
    cat otg.yml | envsubst | otgen run -k -a https://localhost:8443 -m flow | otgen transform -m flow | otgen display -m table
    ```

3. The same, but with byte instead of frame count (only receive stats are reported)

    ```Shell
    cat otg.yml | envsubst | otgen run -k -a https://localhost:8443 -m flow | otgen transform -m flow -c bytes | otgen display -m table
    ```

4. Now report packet per second rate, as a line chart (end with `Crtl-c`)

    ```Shell
    cat otg.yml | envsubst | otgen run -k -a https://localhost:8443 -m flow | otgen transform -m flow -c pps | otgen display -m chart
    ```

## Run OTG traffic flows with Python `snappi` library

1. Setup virtualenv for Python

    ```Shell
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```

2. Run flows via snappi script, reporting port metrics

    ```Shell
    ./snappi/otg-flows.py -m port
    ```

3. Run flows via snappi script, reporting port flow

    ```Shell
    ./snappi/otg-flows.py -m flow
    ```

## Destroy the Keysight Elastic Network Generator deployment

To stop the deployment, run:

```Shell
sudo docker-compose down
```
