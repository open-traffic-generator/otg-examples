# Ixia-c ARP, BGP and traffic with FRR as a DUT

## Overview
This lab demonstrates validation of an FRR DUT for basic BGP peering, prefix announcements and passing of traffic between announced subnets. To run OTG protocols and flows, Ixia-c Traffic and Protocol Engine are used.

The same setup can be brought up using one of two methods:

  * [Docker Compose](https://docs.docker.com/compose/)
  * [Containerlab](https://containerlab.dev/)

Also, the same OTG test logic can be executed using one of two OTG clients:

  * [`curl`](https://otg.dev/clients/curl/)
  * [`otgen`](https://otg.dev/clients/otgen/)

Each method has its own benefits. With `curl`, you can try each individual OTG API call needed to complete the test. On the other hand, `otgen` demonstrates how all these steps could be easily executed with a single command. By comparing with `curl` `get_metrics` or `get_state` requests output, you can better understands the logic `otgen` is using to wait for the results of previous API calls to converge or complete. Finally, you can use [`otgen run`](https://github.com/open-traffic-generator/otgen/blob/main/cmd/run.go) source code as a starting point for custom test logic you could develop using [`gosnappi`](https://otg.dev/clients/gosnappi/) library.

## Lab configuration

### Diagram

![Diagram](./diagram.drawio.svg)

### Layer 3 topology and generated traffic flows

![IP Diagram](./ip-diagram.drawio.svg)

### OTG

The lab uses [`otg.json`](otg.json) configuration file with the following properties:

![OTG Diagram](./otg-diagram.drawio.svg)

To request Ixia-c to use ARP to determine destination MAC address for a flow `f1`, the following flow properties are used. The `dst` parameter in the `packet` section uses `auto` mode. In addition, `tx_rx` section has to use names of emulated devices' IP interfaces, as in `"tx_names":  ["otg1.eth[0].ipv4[0]"]`.

```JSON
  "flows":  [
    {
      "tx_rx":  {
        "choice":  "device",
        "device":  {
          "mode":  "mesh",
          "tx_names":  [
            "otg1.eth[0].ipv4[0]"
          ],
          "rx_names":  [
            "otg2.eth[0].ipv4[0]"
          ]
        }
      },
      "packet":  [
        {
          "choice":  "ethernet",
          "ethernet":  {
            "dst":  {
              "choice":  "auto",
              "auto":  "00:00:00:00:00:00"
            },
            "src":  {
              "choice":  "value",
              "value":  "02:00:00:00:01:aa"
            }
          }
        }
      ]
    }
  ]
```

## Quick start

1. Clone this repository

    ```Shell
    git clone --recursive https://github.com/open-traffic-generator/otg-examples.git
    cd otg-examples/docker-compose/cpdp-frr
    ```

2. To run all the steps below at once using Docker Compose, execute:

    ```Shell
    make all
    make clean
    ```

3. To use Containerlab option, run:

    ```Shell
    make all-clab
    make clean
    ```

## Prerequisites

* Linux host or VM with sudo permissions and Docker support
* [Docker](https://docs.docker.com/engine/install/)
* `curl` command
* `watch` command (optional)
* `jq` command (optional)

## Install components

1. Install `docker-compose` and add yourself to `docker` group. Logout for group changes to take effect.

    ```Shell
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo usermod -aG docker $USER
    logout
    ```

2. For Containerlab use case, install the latest release. For more installation options see [here](https://containerlab.dev/install/).

    ```Shell
    bash -c "$(curl -sL https://get.containerlab.dev)"
    ```

3. Install `otgen` tool, version `0.6.2` or later.

    ```Shell
    bash -c "$(curl -sL https://get.otgcdn.net/otgen)" -- -v 0.6.2
    ```

4. Make sure `/usr/local/bin` is in your `$PATH` variable (by default this is not the case on CentOS 7)

    ```Shell
    cmd=docker-compose
    dir=/usr/local/bin
    if ! command -v ${cmd} &> /dev/null && [ -x ${dir}/${cmd} ]; then
      echo "${cmd} exists in ${dir} but not in the PATH, updating PATH to:"
      PATH="/usr/local/bin:${PATH}"
      echo $PATH
    fi
    ```

5. Clone this repository

    ```Shell
    git clone --recursive https://github.com/open-traffic-generator/otg-examples.git
    ```

## Docker Compose option to deploy the lab

1. Launch the deployment using Docker Compose

    ```Shell
    cd otg-examples/docker-compose/cpdp-frr
    docker-compose up -d
    sudo docker ps
    ```

2. Make sure you have all five containers running. The result should look like this

    ```Shell
    CONTAINER ID   IMAGE                                                              COMMAND                  CREATED         STATUS         PORTS                                                                                      NAMES
    0ea1e56720ac   ghcr.io/open-traffic-generator/ixia-c-protocol-engine:1.00.0.337   "/docker_im/opt/Ixia…"   3 seconds ago   Up 3 seconds                                                                                              cpdp-frr_protocol_engine_1_1
    44f4c9fb8b3e   ghcr.io/open-traffic-generator/ixia-c-protocol-engine:1.00.0.337   "/docker_im/opt/Ixia…"   3 seconds ago   Up 3 seconds                                                                                              cpdp-frr_protocol_engine_2_1
    6e50d4cad6a6   ghcr.io/open-traffic-generator/keng-controller:0.1.0-3             "./bin/controller --…"   4 seconds ago   Up 4 seconds                                                                                              cpdp-frr_controller_1
    7fe400f12196   quay.io/frrouting/frr:8.4.2                                        "/sbin/tini -- /usr/…"   4 seconds ago   Up 3 seconds                                                                                              cpdp-frr_frr_1
    2a7e1c124cbd   ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85      "./entrypoint.sh"        4 seconds ago   Up 3 seconds   0.0.0.0:5556->5556/tcp, :::5556->5556/tcp, 0.0.0.0:50072->50071/tcp, :::50072->50071/tcp   cpdp-frr_traffic_engine_2_1
    cbc0a64278cc   ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.85      "./entrypoint.sh"        4 seconds ago   Up 3 seconds   0.0.0.0:5555->5555/tcp, :::5555->5555/tcp, 0.0.0.0:50071->50071/tcp, :::50071->50071/tcp   cpdp-frr_traffic_engine_1_1
    p
    ```

3. Interconnect traffic engine containers via a veth pair

    ```Shell
    sudo ../../utils/connect_containers_veth.sh cpdp-frr_traffic_engine_1_1 cpdp-frr_frr_1 veth0 veth1
    sudo ../../utils/connect_containers_veth.sh cpdp-frr_traffic_engine_2_1 cpdp-frr_frr_1 veth2 veth3
    ```

4. Check traffic and protocol engine logs to see if they picked up veth interfaces

    ```Shell
    sudo docker logs cpdp-frr_traffic_engine_1_1
    sudo docker logs cpdp-frr_traffic_engine_2_1
    sudo docker logs cpdp-frr_protocol_engine_1_1
    sudo docker logs cpdp-frr_protocol_engine_2_1
    ```

## Containerlab option to deploy the lab

1. Launch the deployment using Containerlab

    ```Shell
    cd otg-examples/docker-compose/cpdp-frr
    sudo -E containerlab deploy
    ```

## Run tests, `curl` option

1. Apply config

    ```Shell
    OTG_HOST="https://localhost:8443"
    curl -k "${OTG_HOST}/config" \
        -H "Content-Type: application/json" \
        -d @otg.json
    ```

2. Start protocols

    ```Shell
    curl -k "${OTG_HOST}/control/state" \
        -H  "Content-Type: application/json" \
        -d '{"choice": "protocol","protocol": {"choice": "all","all": {"state": "start"}}}'
    ```

3. Fetch ARP table

    ```Shell
    curl -sk "${OTG_HOST}/monitor/states" \
        -X POST \
        -H  'Content-Type: application/json' \
        -d '{ "choice": "ipv4_neighbors" }'
    ```

4. Fetch BGP metrics (stop with `Ctrl-c`)

    ```Shell
    watch -n 1 "curl -sk \"${OTG_HOST}/monitor/metrics\" \
        -X POST \
        -H  'Content-Type: application/json' \
        -d '{ \"choice\": \"bgpv4\" }'"
    ```

5. Fetch BGP prefixes

    ```Shell
    curl -sk "${OTG_HOST}/monitor/states" \
        -X POST \
        -H  'Content-Type: application/json' \
        -d '{ "choice": "bgp_prefixes" }'
    ```

6. Start transmitting flows

    ```Shell
    curl -sk "${OTG_HOST}/control/state" \
        -H  "Content-Type: application/json" \
        -d '{"choice": "traffic", "traffic": {"choice": "flow_transmit", "flow_transmit": {"state": "start"}}}'
    ```

7. Fetch flow metrics (stop with `Ctrl-c`)

    ```Shell
    watch -n 1 "curl -sk \"${OTG_HOST}/monitor/metrics\" \
        -X POST \
        -H  'Content-Type: application/json' \
        -d '{ \"choice\": \"flow\" }'"
    ```

8. Fetch port metrics

    ```Shell
    curl -sk "${OTG_HOST}/monitor/metrics" \
        -X POST \
        -H  'Content-Type: application/json' \
        -d '{ "choice": "port" }'
    ```

## Run tests, `otgen` option

1. Use one `otgen run` command to repeat all of the steps above. Note `--rxbgp 2x` parameter. We use it to tell `otgen` it should wait, after starting the protocols, until twice as many routes were received from the DUT, than were advertised by KENG. For our lab configuration it would be the signal that BGP protocol has converged. In other setups this parameter might be different.

    ```Shell
    export OTG_API="https://localhost:8443"
    otgen --log info run --insecure --file otg.json --json --rxbgp 2x --metrics flow | jq
    ```

2. To format output as a table, use the modified command below. Note, there will be no log output in this case, so be patient to wait for the table output to appear.

    ```Shell
    otgen run --insecure --file otg.json --json --rxbgp 2x --metrics flow | otgen transform --metrics flow | otgen display --mode table
    ```

## Destroy the lab

* To destroy the lab brought up via Docker Compose, including veth pairs, use:

    ```Shell
    docker-compose down
    ```

* To destroy the lab brought up via Containerlab, use:

    ```Shell
    sudo containerlab destroy -c
    ```

## Credits

* `connect_containers_veth.sh` copyright of [Levente Csikor](https://github.com/cslev/add_veth_to_docker/), with modifications to replace `ifconfig` with `ip link`.
