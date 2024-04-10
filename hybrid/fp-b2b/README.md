# OpenConfig FeatureProfiles OTG Back-2-Back Test with Ixia-c in Hybrid Mode

## Overview

This lab is an introduction to [OpenConfig](https://openconfig.net/) [FeatureProfiles](https://github.com/openconfig/featureprofiles) test suites built with the [Open Traffic Generator API](https://otg.dev).

> Feature profiles define groups of OpenConfig paths that can be invoked on network devices. A feature profile may contain configuration, telemetry, operational or any other paths that a device exposes. Example management plane device APIs are gNMI, and gNOI. Example control plane APIs are gRIBI, and protocols such as BGP, IS-IS.

> Feature profiles also include a suite of tests for validating the network device behavior for each defined feature.

In FeatureProfiles terminology, a term `ATE` is used to refer to a Traffic Generator, and it stands for `Automated Test Equipment`. This lab uses [Keysight Elastic Network Generator](../../KENG.md) with containerized [Ixia-c](https://ixia-c.dev) test ports as the `ATE`.

FeatureProfiles use [Ondatra](https://github.com/openconfig/ondatra) framework for writing and running tests against both real and containerized network devices. When executing a test via the Open Traffic Generator API, it uses `gosnappi` client library internally.

There are several ways to run FeatureProfiles tests. In this example, we're demonstrating a use of so called `static binding`:

> The static binding supports ATE based testing with a real hardware device. It assumes that there is one ATE hooked up to one DUT in the testbed, and their ports are connected pairwise.

Although original intent of `static binding` is to describe a connection between the ATE and a hardware Device Under Test (DUT), it can also be used to describe a back-2-back ATE setup, w/o a DUT. Such setup is helpful to validate basic ATE operations within FeatureProfiles test framework. In this lab, we're using [otgb2b.binding](otgb2b.binding) paired with [otgb2b.testbed](https://github.com/open-traffic-generator/featureprofiles/blob/static/feature/experimental/otg_only/otgb2b.testbed) testbed specification to describe such back-2-back ATE connection.

## Prerequisites

* Linux host or VM with sudo permissions and Docker support
* [Docker](https://docs.docker.com/engine/install/)
* [Go](https://go.dev/dl/) version 1.18 or later
* `envsubst` command

## Initial setup

1. Clone this repository

    ```Shell
    git clone --recursive https://github.com/open-traffic-generator/otg-examples.git
    OTGLABDIR="${PWD}/otg-examples/hybrid/fp-b2b"
    cd "${OTGLABDIR}"
    ```

2. Pull Docker images (KENG Hybrid Operator currently requires Docker images to be present locally)

    ```Shell
    sudo docker compose --project-directory "${OTGLABDIR}" pull operator
    make pull
    ```

4. Start and configure KENG Hybrid Operator

    ```Shell
    sudo docker compose --project-directory "${OTGLABDIR}" up -d
    sleep 2
    curl --data-binary @"${OTGLABDIR}/ixiatg-configmap.yml" http://localhost:35000/config
    ```

### Create Ixia-c B2B deployment

1. Create a back-2-back connection using `veth` pair.

    ```Shell
    export OTG_PORT1="veth0"
    export OTG_PORT2="veth1"
    sudo ip link add name ${OTG_PORT1} type veth peer name ${OTG_PORT2}
    sudo ip link set dev ${OTG_PORT1} up
    sudo ip link set dev ${OTG_PORT2} up
    ```

    Instead of `veth` pair, you could also use one of the following methods. In such case, please initialize `OTG_PORT1` and `OTG_PORT2` env vars with correct interface names.

    * a physical cable between two network interface cards
    * a layer-2 switch between two network interface cards


2. Request the `ixia-c-operator` to bring up Ixia-c test ports using [ixia-c-hybrid.yml](ixia-c-hybrid.yml) deployment manifest. Note how `envsubst` command will insert proper interface names you're using into the manifest before it gets submitted by the `curl` to the `ixia-c-operator` API.

    ```Shell
    cat "${OTGLABDIR}/ixia-c-hybrid.yml" | envsubst | curl --data-binary @- http://localhost:35000/create
    ```

### Run FeatureProfiles OTG back-2-back test

1. Run FeatureProfiles OTG B2B test

    ```Shell
    cd featureprofiles/feature/experimental/otg_only
    go test -v otgb2b_test.go -testbed otgb2b.testbed -binding "${OTGLABDIR}/otgb2b.binding"
    ```

## Cleanup

To remove all the components we created, run:

```Shell
cat "${OTGLABDIR}/ixia-c-hybrid.yml" | envsubst | curl -d @- http://localhost:35000/delete
sudo ip link del name ${OTG_PORT1}
sudo docker compose --project-directory "${OTGLABDIR}" down
cd "${OTGLABDIR}"
```
