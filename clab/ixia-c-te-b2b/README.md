# Containerlab with Ixia-c Traffic Engine Back-2-Back

## Overview
In this Containerlab-based setup, we demonstrate how to directly deploy Ixia-c Traffic Engine nodes, instead of using Ixia-c-one node type.

## Preprequisites

* Linux host or VM with sudo permissions and Docker support
* `git` - how to install depends on your Linux distro.
* [Docker](https://docs.docker.com/engine/install/)
* [Containerlab](https://containerlab.dev/install/)
* [otgen](https://github.com/open-traffic-generator/otgen)

    ```Shell
    curl -L "https://github.com/open-traffic-generator/otgen/releases/download/v0.2.0/otgen_0.2.0_$(uname -s)_$(uname -m).tar.gz" | tar xzv otgen
    sudo mv otgen /usr/local/bin/otgen
    sudo chmod +x /usr/local/bin/otgen
    ```

## Clone the repository

1. Clone this repository to the Linux host where you want to run the lab. Do this only once.

```Shell
git clone --recurse-submodules https://github.com/open-traffic-generator/otg-examples.git
````

2. Navigate to the lab folder

```Shell
cd otg-examples/clab/ixia-c-te-b2b
````

## Deploy a lab

```Shell
sudo containerlab deploy
````

## Run `otgen` test

```Shell
cat otg.yml | otgen run -k -a https://clab-ixcteb2b-ixc | otgen transform -m port | otgen display -m table
````

## Destroy the lab

```Shell
sudo containerlab destroy
````
