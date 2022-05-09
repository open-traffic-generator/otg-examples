# Remote Triggered Blackhole Scenario

## Prepare (once)

```Shell
docker build -t gosnappi:local .
````

## Launch with ContainerLab

```Shell
sudo -E containerlab deploy -t rtbh.yml
````

## Run OTG Test

```Shell
DMAC=`docker exec clab-rtbh-pe-router vtysh -c  'sh interface eth2 | include HWaddr' | awk "{print \\$2}"`
echo $DMAC
docker exec -it clab-rtbh-gosnappi bash -c "go test -dstMac=${DMAC}"
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

