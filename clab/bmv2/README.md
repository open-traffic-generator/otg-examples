# P4 Behavioral Model Switch traffic test with Ixia-c-one

## Overview
In this setup, we demonstrate how to test P4 code using BMV2 switch with Ixia-c-one in Containerlab.

### Diagram

### Layer 3 topology and generated traffic flows


## Prerequisites

* Linux host or VM with sudo permissions and Docker support
* `git` - how to install depends on your Linux distro.
* [Docker](https://docs.docker.com/engine/install/)
* [Containerlab](https://containerlab.dev/install/)

## Clone the repository

1. Clone this repository to the Linux host where you want to run the lab. Do this only once.

```Shell
git clone https://github.com/open-traffic-generator/otg-examples.git
```

2. Navigate to the lab folder

```Shell
cd otg-examples/clab/bmv2
````

## Deploy a lab

```Shell
sudo containerlab deploy
````

## Run traffic

1. Read MAC addresses assigned to the nodes

```Shell
TE1SMAC=`cat clab-ixctedut/topology-data.json | jq -r '.links[0]["a"].mac'`
TE1DMAC=`cat clab-ixctedut/topology-data.json | jq -r '.links[0]["z"].mac'`
TE2SMAC=`cat clab-ixctedut/topology-data.json | jq -r '.links[1]["a"].mac'`
TE2DMAC=`cat clab-ixctedut/topology-data.json | jq -r '.links[1]["z"].mac'`
```

2. Run traffic defined in [otg.yml](otg.yml) with `otgen` tool, taking care to replace stub MAC addresses with current values

```Shell
cat otg.yml | \
sed "s/00:00:00:00:11:aa/$TE1SMAC/g" | sed "s/00:00:00:00:11:bb/$TE1DMAC/g" | \
sed "s/00:00:00:00:22:aa/$TE2SMAC/g" | sed "s/00:00:00:00:22:bb/$TE2DMAC/g" | \
otgen run -k 2>/dev/null| \
otgen transform -m port | \
otgen display -m table
````

## Destroy the lab

```Shell
sudo containerlab destroy
````
