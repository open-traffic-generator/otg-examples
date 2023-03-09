# Static B2B LAG

## Overview
This is a simple lab where an Ixia-c Traffic Engine nodes has two pairs of traffic ports connected back-2-back in a Containerlab environment. The goal is to demonstrate how to create a static Link Aggregation Group (LAG) consisting of from two ports and run traffic over the LAG interface.

## Prerequisites

* Linux host or VM with sudo permissions and Docker support. See [some ready-to-use options below](#options-for-linux-vm-deployment-for-containerlab)
* `git` - how to install depends on your Linux distro.
* [Docker](https://docs.docker.com/engine/install/)
* [Containerlab](https://containerlab.dev/install/)

## Clone the repository

1. Clone this repository to the Linux host where you want to run the lab. Do this only once.

    ```Shell
    git clone --recurse-submodules https://github.com/open-traffic-generator/otg-examples.git
    ```

2. Navigate to the lab folder

    ```Shell
    cd otg-examples/clab/ixia-c-one-b2b-lag
    ```

## Install components

```Shell
make install
```

## Deploy a lab

```Shell
sudo -E containerlab deploy -t topo.yml
```

## Run otgen test

```Shell
make run
```

## Destroy the lab

```Shell
sudo -E containerlab destroy -t topo.yml
```
