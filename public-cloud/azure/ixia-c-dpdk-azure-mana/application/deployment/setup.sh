# Enable 2MB hugepages.
echo 2048 | tee /sys/devices/system/node/node*/hugepages/hugepages-2048kB/nr_hugepages

# Assuming use of eth1 for DPDK in this demo
PRIMARY="eth1"

SECONDARY="`ip -br link show master $PRIMARY | awk '{ print $1 }'`"

# Set MANA interfaces DOWN before starting DPDK
ip link set $PRIMARY down
ip link set $SECONDARY down

## Move synthetic channel to user mode and allow it to be used by NETVSC PMD in DPDK
DEV_UUID=$(basename $(readlink /sys/class/net/$PRIMARY/device))
NET_UUID="f8615163-df3e-46c5-913f-f2d2f965ed0e"
modprobe uio_hv_generic
echo $NET_UUID > /sys/bus/vmbus/drivers/uio_hv_generic/new_id
echo $DEV_UUID > /sys/bus/vmbus/drivers/hv_netvsc/unbind
echo $DEV_UUID > /sys/bus/vmbus/drivers/uio_hv_generic/bind

####################################################################################

# Assuming use of eth2 for DPDK in this demo
PRIMARY="eth2"

SECONDARY="`ip -br link show master $PRIMARY | awk '{ print $1 }'`"

# Set MANA interfaces DOWN before starting DPDK
ip link set $PRIMARY down
ip link set $SECONDARY down

## Move synthetic channel to user mode and allow it to be used by NETVSC PMD in DPDK
DEV_UUID=$(basename $(readlink /sys/class/net/$PRIMARY/device))
# NET_UUID="f7615163-df3e-46c5-913f-f2d2f965ed0e"
modprobe uio_hv_generic
# echo $NET_UUID > /sys/bus/vmbus/drivers/uio_hv_generic/new_id
echo $DEV_UUID > /sys/bus/vmbus/drivers/hv_netvsc/unbind
echo $DEV_UUID > /sys/bus/vmbus/drivers/uio_hv_generic/bind