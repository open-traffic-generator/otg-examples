# OpenConfig FeatureProfiles OTG Back-2-Back Test with Ixia-c in Hybrid Mode

## Overview

## Prerequisites

1. Linux VM
2. [Go](https://go.dev/dl/) version 1.18 or later
3. Docker
4. `envsubst`
5. Clone this repository

    ```Shell
    git clone https://github.com/open-traffic-generator/otg-examples.git
    OTGEXDIR="${PWD}/otg-examples/hybrid/fp-b2b"
    ```

## Setup

### Pull Docker images

```Shell
docker pull ghcr.io/open-traffic-generator/licensed/ixia-c-controller:0.0.1-3662
docker pull ghcr.io/open-traffic-generator/ixia-c-gnmi-server:1.9.9
docker pull ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.19
docker pull ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.243
```

### Start Ixia-c operator

TODO ixia-c-operator public image

```Shell
docker run -d --privileged -v /var/run/docker.sock:/var/run/docker.sock --pid=host --net=host --user=root --name=ixia-c-operator ixia-c-operator:local --server-bind-address=:35000
curl --data-binary @"${OTGEXDIR}/ixiatg-configmap.yml" http://localhost:35000/config
```

### Create Ixia-c B2B deployment

1. Create back-2-back connection using veth pair

    ```Shell
    sudo ip link add name veth0 type veth peer name veth1
    sudo ip link set dev veth0 up
    sudo ip link set dev veth1 up
    export OTG_PORT1="veth0"
    export OTG_PORT2="veth1"
    ```

2. Deploy Ixia-c over a pair the veth pair

    ```Shell
    cat "${OTGEXDIR}/ixia-c-hybrid.yml" | envsubst | curl --data-binary @- http://localhost:35000/create
    ```

### Run FP OTG back-2-back test

1. Clone FeatureProfiles fork from Open Traffic Generator org. The back-2-back tests we're going to be using a published under a `static` branch we need to clone:

    ```Shell
    git clone -b static https://github.com/open-traffic-generator/featureprofiles.git
    ```

2. Run FeatureProfiles OTG B2B test

    ```Shell
    cd featureprofiles/feature/experimental/otg_only
    go test -v otgb2b_test.go -testbed otgb2b.testbed -binding "${OTGEXDIR}/otgb2b.binding"
    ```

## Cleanup

```Shell
cat "${OTGEXDIR}/ixia-c-hybrid.yml" | envsubst | curl -d @- http://localhost:35000/delete
```
