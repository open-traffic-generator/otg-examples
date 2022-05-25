# Remote Triggered Blackhole Scenario

## Overview

Remote Triggered Blackhole (RTBH) is a common DDoS mitigation technique. It uses BGP anouncements to request an ISP to drop all traffic to an IP address under a DDoS attack.

## Preprequisites

* Linux host or VM with sudo permissions and Docker support. If you're on Mac, an example below can be used to create an Ubuntu 22.04LTS VM `otg-demo`

    ```Shell
    brew install --cask multipass
    multipass version
    multipass launch 22.04 -n otg-demo -c4 -m8G -d32G
    multipass shell otg-demo
    ````

* `git` - how to install depends on your Linux distro. The example above comes with `git` preinstalled.
* [Docker](https://docs.docker.com/engine/install/)
* [Containerlab](https://containerlab.dev/install/)

## Clone the repository

1. Clone this repository to the Linux host where you want to run the lab. Do this only once.

```Shell
git clone --single-branch https://github.com/OpenIxia/otg-demo.git
````

2. Navigate to the lab folder

```Shell
cd otg-demo/clab/rtbh
````

## Prepare a `gosnappi` container image

Run the following only once, to build a container image where `go test` command would execute. This step will pre-load all the Go modules needed by the test into the local `gosnappi` image. 

```Shell
sudo docker build -t gosnappi:local .
````

## Deploy the topology with Containerlab

```Shell
sudo -E containerlab deploy -t topo.yml
````

## Open DDoS Protect Dashboard

[//]: # (TODO add show url capabilities to sflow)

Access the DDoS Protect screen at [http://localhost:8008/app/ddos-protect/html/](http://localhost:8008/app/ddos-protect/html/)

## Run OTG Test

```Shell
DMAC=`docker exec clab-rtbh-pe-router vtysh -c  'sh interface eth2 | include HWaddr' | awk "{print \\$2}"`
docker exec -it clab-rtbh-gosnappi bash -c "go test -dstMac=${DMAC}"
````

## Destroy the lab

```Shell
sudo -E containerlab destroy -t topo.yml
````

## Misc
### CLI access to nodes

```Shell
sudo docker exec -it clab-rtbh-pe-router vtysh
sudo docker exec -it clab-rtbh-ce-router vtysh

sudo docker exec -it clab-rtbh-ixia sh
````

## Credits

Original lab design: 
  * [BGP Remotely Triggered Blackhole (RTBH)](https://blog.sflow.com/2022/04/bgp-remotely-triggered-blackhole-rtbh.html)
  * [sflow-rt github repository](https://github.com/sflow-rt/containerlab)
