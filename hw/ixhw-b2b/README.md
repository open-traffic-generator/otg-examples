# OTG with Ixia L23 Hardware - back-to-back setup

## Overview
TODO

## Prerequisites

* Linux host or VM with sudo permissions and Docker support
* [Docker](https://docs.docker.com/engine/install/)
* Python3.9
* Ixia hardware chassis or appliance with IxOS 9.2 or higher

## Install components

1. Install `docker-compose`

    ```Shell
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
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

## Deploy KENG Controller

1. Launch the deployment

    ```Shell
    sudo docker-compose up -d
    ```

2. Make sure you have all three containers running:

    ```Shell
    sudo docker ps
    ```

3. Initialize environment variables with locations of Ixia L23 hardware ports. Replace `ixos_ip_address`, `slot_number_X`, `port_number_X` with values matching your equipment.

    ```Shell
    export OTG_LOCATION_P1="ixos_ip_address;slot_number_1;port_number_1"
    export OTG_LOCATION_P2="ixos_ip_address;slot_number_2;port_number_2"
    ```


## Destroy the KENG Controller

To stop the KENG Controller:

```Shell
docker-compose down
```
