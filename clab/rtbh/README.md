# Remote Triggered Blackhole Scenario

## Overview

Remote Triggered Blackhole (RTBH) is a common DDoS mitigation technique. It uses BGP anouncements to request an ISP to drop all traffic to an IP address under a DDoS attack.

## Preprequisites

* Linux host or VM with sudo permissions and Docker support. If you're on Mac, an example below can be used to create an Ubuntu 20.04LTS VM `otg-demo`, using [Multipass](https://multipass.run/). Ubuntu 22.04 is not yet supported for this test.

    ```Shell
    multipass launch 20.04 -n otg-demo -c4 -m8G -d32G
    multipass shell otg-demo
    ````

* `git` - how to install depends on your Linux distro. The example above comes with `git` preinstalled.
* [Docker](https://docs.docker.com/engine/install/), or `sudo apt install docker.io` for Ubuntu 20.04LTS VM example
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

As the lab is being deployed, in Containerlab output you should see a line like this:

  > DDoS Protect Dashboard 🛡️  http://some-ip-address:8008/app/ddos-protect/html/index.html

Open the link in the browser to see the DDoS Protect Dashboard

## Run OTG Test

Execute the test by running `go test` in `clab-rtbh-gosnappi` container. Note, it will take some time for Golang to compile the test binary, so expect a delay before the test starts running.

```Shell
DMAC=`sudo docker exec clab-rtbh-pe-router vtysh -c  'sh interface eth2 | include HWaddr' | awk "{print \\$2}"`
sudo docker exec -it clab-rtbh-gosnappi bash -c "go test -dstMac=${DMAC}"
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
