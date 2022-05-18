# Remote Triggered Blackhole Scenario

## Prepare (once)

[//]: # (TODO Create a Linux VM)

```Shell
docker build -t gosnappi:local .
````

## Launch with ContainerLab

```Shell
sudo -E containerlab deploy -t rtbh.yml
````

## Open DDoS Protect Dashboard

[//]: # (TODO add show url capabilities to sflow)

Access the DDoS Protect screen at [http://localhost:8008/app/ddos-protect/html/](http://localhost:8008/app/ddos-protect/html/)

## Run OTG Test

```Shell
DMAC=`docker exec clab-rtbh-pe-router vtysh -c  'sh interface eth2 | include HWaddr' | awk "{print \\$2}"`
docker exec -it clab-rtbh-gosnappi bash -c "go test -v -dstMac=${DMAC} -pktCount=500 -pktPPS=100"
````

## Destroy the lab

```Shell
sudo -E containerlab destroy -t rtbh.yml
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
