#!/bin/bash

# Get pci addresses
PCI_ADDRESS1="30d5:00:02.0"
PCI_ADDRESS2="ea49:00:02.0"
PCI_ADDRESS3="aeca:00:02.0"
PCI_ADDRESS4="5850:00:02.0"


# Allocate hugepages
mkdir -p /mnt/huge
mount -t hugetlbfs nodev /mnt/huge
echo 4536 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
cat  /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages


# Deploy TE1 on port 5551. It uses PCI_ADDRESS1 and CPU cores 0,1,2
sudo docker run --rm -d --net=host --privileged --cpuset-cpus "0,1,2" \
--name TE1-5551 \
-e OPT_LISTEN_PORT=5551 \
-e ARG_IFACE_LIST="pci@$PCI_ADDRESS1" \
-v /mnt/huge:/mnt/huge \
-v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages \
-v /sys/bus/pci/drivers:/sys/bus/pci/drivers \
-v /sys/devices/system/node:/sys/devices/system/node \
-v /dev:/dev \
ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.45-with-perf 


# Deploy TE2 on port 5552. It uses PCI_ADDRESS2 and CPU cores 3,4,5
sudo docker run --rm -d --net=host --privileged --cpuset-cpus "3,4,5" \
--name TE2-5552 \
-e OPT_LISTEN_PORT=5552 \
-e ARG_IFACE_LIST="pci@$PCI_ADDRESS2" \
-v /mnt/huge:/mnt/huge \
-v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages \
-v /sys/bus/pci/drivers:/sys/bus/pci/drivers \
-v /sys/devices/system/node:/sys/devices/system/node \
-v /dev:/dev \
ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.45-with-perf 


# Deploy TE3 on port 5553. It uses PCI_ADDRESS3 and CPU cores 6,7,8
sudo docker run --rm -d --net=host --privileged --cpuset-cpus "6,7,8" \
--name TE3-5553 \
-e OPT_LISTEN_PORT=5553 \
-e ARG_IFACE_LIST="pci@$PCI_ADDRESS3" \
-v /mnt/huge:/mnt/huge \
-v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages \
-v /sys/bus/pci/drivers:/sys/bus/pci/drivers \
-v /sys/devices/system/node:/sys/devices/system/node \
-v /dev:/dev \
ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.45-with-perf 

# Deploy TE4 on port 5554. It uses PCI_ADDRESS4 and CPU cores 9,10,11
sudo docker run --rm -d --net=host --privileged --cpuset-cpus "9,10,11" \
--name TE4-5554 \
-e OPT_LISTEN_PORT=5554 \
-e ARG_IFACE_LIST="pci@$PCI_ADDRESS4" \
-v /mnt/huge:/mnt/huge \
-v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages \
-v /sys/bus/pci/drivers:/sys/bus/pci/drivers \
-v /sys/devices/system/node:/sys/devices/system/node \
-v /dev:/dev \
ghcr.io/open-traffic-generator/ixia-c-traffic-engine:1.6.0.45-with-perf 
