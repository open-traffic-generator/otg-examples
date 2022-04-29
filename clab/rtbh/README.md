# Remote Triggered Blackhole Scenario

## Launch with ContainerLab

```Shell
sudo -E containerlab deploy -t rtbh.yml
````

## Run OTG Test

```Shell
DMAC=`docker exec clab-rtbh-pe-router vtysh -c  'sh interface eth2 | include HWaddr' | awk "{print \\$2}"`
echo $DMAC
go run otg-ipv4-traffic.go -dstMac="${DMAC}"
````

## Misc
### CLI access to nodes

```Shell
docker exec -it clab-rtbh-pe-router vtysh
docker exec -it clab-rtbh-ce-router vtysh

docker exec -it clab-rtbh-attacker sh
docker exec -it clab-rtbh-victim sh
````

