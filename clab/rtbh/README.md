# Remote Triggered Blackhole Scenario

[//]: # (TODO Create a Linux VM)

## Preprequisites

* Linux host or VM with sudo permissions and Docker support
* [Docker](https://docs.docker.com/engine/install/)
* [Containerlab](https://containerlab.dev/install/)

## Prepare a `gosnappi` container image

Run the following only once, to build a container image where `go test` command would execute. This step will pre-load all the Go modules needed by the test into the local `gosnappi` image. Note, this step is optional, if you have Golang installed on the Linux host and can run `go test` locally on it.

```Shell
docker build -t gosnappi:local .
````

## Deploy the topology with ContainerLab

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
docker exec -it clab-rtbh-pe-router vtysh
docker exec -it clab-rtbh-ce-router vtysh

docker exec -it clab-rtbh-ixia sh
````

## Credits

Original lab design: 
  * [BGP Remotely Triggered Blackhole (RTBH)](https://blog.sflow.com/2022/04/bgp-remotely-triggered-blackhole-rtbh.html)
  * [sflow-rt github repository](https://github.com/sflow-rt/containerlab)
