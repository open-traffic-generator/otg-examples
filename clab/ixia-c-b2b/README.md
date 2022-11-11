# Hello, snappi!  Welcome to the Clab!

## Overview
This is a simple lab where an Ixia-c-one node has two traffic ports connected back-2-back in a Containerlab environment. The goal is to demonstrate basics of creating a Python program to control Ixia-c via [`snappi`](https://github.com/open-traffic-generator/snappi) SDK.

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
cd otg-examples/clab/ixia-c-b2b
```

## Prepare a `snappi` container image

Run the following only once, to build a container image where `snappi` program will execute:

```Shell
sudo docker build -t snappi:local .
```

## Deploy a lab

```Shell
sudo -E containerlab deploy -t topo.yml
```

## Run snappi test

```Shell
sudo docker exec -it clab-ixcb2b-snappi bash -c "python otg.py"
```

## Destroy the lab

```Shell
sudo -E containerlab destroy -t topo.yml
```

## Options for Linux VM deployment for Containerlab

### Containerlab VM deployment on Mac using Multipass

1. If you're on Mac, an example below can be used to create an Ubuntu 20.04LTS VM `otg-demo`, using [Multipass](https://multipass.run/). Ubuntu 22.04 is not yet supported for this test.

```Shell
multipass launch 20.04 -n otg-demo -c4 -m8G -d32G
multipass shell otg-demo
sudo apt update && sudo apt install docker.io -y
bash -c "$(curl -sL https://get.containerlab.dev)"
```

2. Delete the VM after testing is done

```Shell
multipass stop otg-demo
multipass delete otg-demo
```

###  Containerlab VM deployment in Google Cloud

1. Create a VM in a default VPC

```Shell
gcloud compute instances create otg-demo \
--subnet=default \
--machine-type=e2-standard-8 \
--image-family=ubuntu-2004-lts \
--image-project=ubuntu-os-cloud \
--boot-disk-size=30GB \
--boot-disk-device-name=otg-demo \
--tags=otg-demo

gcloud compute ssh otg-demo
sudo apt update && sudo apt install docker.io -y
bash -c "$(curl -sL https://get.containerlab.dev)"
```

2. Delete all resources and the VM after testing is done

```Shell
gcloud compute instances delete otg-demo
```

## Misc

### CLI access to nodes

  ```Shell
  # ixia-c
  sudo docker exec -it clab-ixcb2b-ixia-c sh
  sudo docker exec -it clab-ixcb2b-snappi bash
  ```

## Credits

This work os based on: 
  * [Hello, snappi!](https://github.com/open-traffic-generator/ixia-c/blob/main/docs/hello-snappi.md)
