#!/bin/bash

# Run this script with elevated privileges

TRAFFIC_ENGINE_VERSION="1.6.0.167"
CONTROLLER_VERSION="1.3.0-2"
LICENSE_SERVER_VERSION="latest"

LICENSE_SERVER_IP=localhost

help() {
    echo "Usage: sudo $0 <interface1> [interface2 interface3 interface4]"
}

while getopts "h" option; do
    case $option in
        h) # display Help
            help
            exit;;
    esac
done

if [ "$#" -lt 1 ]; then
  help
  exit
fi

# Checking the CPU core count
num_cpus=$(nproc)
minimum_cpu_count=$(($# * 3))
if ((num_cpus < minimum_cpu_count)); then
    echo "Number of CPUs [$num_cpus] is less than the minimum required CPU cores [$minimum_cpu_count]."
    exit 1
fi

# Allocate 2MB hugepages: 
nr_hugepages=$((1024 * $#))
echo $nr_hugepages | tee /sys/devices/system/node/node*/hugepages/hugepages-2048kB/nr_hugepages

interfaces=()
bus_infos=()
mac_addresses=()

echo "Using the following interface names:"
interfaces+=("$1")
echo "Interface 1: ${interfaces[0]}"

# Extract additional interfaces (if provided) and store them in the array
for ((i = 2; i <= $#; i++)); do
  interfaces+=("${!i}")
  echo "Interface $i: ${interfaces[$((i-1))]}"
done

# Print all interfaces in the array
echo "All interfaces provided: ${interfaces[@]}"

# Clean up .env and .port_macs files
truncate -s 0 .port_macs 
 
for index in "${!interfaces[@]}"; do 
    INTERFACE_NAME="${interfaces[index]}" 
    BUS_INFO=$(ethtool -i $INTERFACE_NAME | grep bus-info | awk '{ print $2 }')
    if [ -z "$BUS_INFO" ]; then
        echo "Error: Failed to get bus info for $INTERFACE_NAME"
        exit 1
    fi

    MAC_ADDRESS=$(ip l sh $INTERFACE_NAME | grep link/ether | awk '{print $2}')
    if [ -z "$MAC_ADDRESS" ]; then
        echo "Error: Failed to get MAC address for $INTERFACE_NAME"
        exit 1
    fi

    # TODO: Add here any binding instruction if needed
    
    bus_infos+=("$BUS_INFO")
    mac_addresses+=("$MAC_ADDRESS")

    echo "$MAC_ADDRESS" >> .port_macs 
done 

echo ""
echo "Content of .port_macs file:" 
cat .port_macs 

#################################################################################### 

# Generate the docker-compose.yaml file
# Define the output file
docker_file_name="docker-compose.yaml"

# Write YAML content to output file
cat <<EOF > "$docker_file_name"
version: '3'
services:
EOF

cat <<EOF >> "$docker_file_name"
  KENG-License-Server:
    image: ghcr.io/open-traffic-generator/keng-license-server:$LICENSE_SERVER_VERSION
    container_name: keng-license-server
    restart: always
    ports:
      - "7443:7443"
      - "9443:9443"
    command: --accept-eula

  controller:
    image: ghcr.io/open-traffic-generator/keng-controller:$CONTROLLER_VERSION
    command: --accept-eula --http-port 8443 --license-servers="$LICENSE_SERVER_IP"
    network_mode: "host"
    restart: always
EOF

# Define Traffic Engine services
for ((i=1; i<=$#; i++)); do
    te_name="TE${i}-555${i}"
    BUS_INFO="${bus_infos[i-1]}"
    core_start=$((($i - 1) * 3))
    core_end=$((($i * 3) - 1))
    core_list=$(seq -s ' ' $core_start $core_end)
    cat <<EOF >> "$docker_file_name"
  $te_name:
    image: ghcr.io/open-traffic-generator/ixia-c-traffic-engine:$TRAFFIC_ENGINE_VERSION
    network_mode: "host"
    privileged: true
    volumes:
      - /mnt/huge:/mnt/huge
      - /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages
      - /sys/bus/pci/drivers:/sys/bus/pci/drivers
      - /sys/devices/system/node:/sys/devices/system/node
      - /dev:/dev
    environment:
      - OPT_LISTEN_PORT=555$i
      - ARG_IFACE_LIST=pci@$BUS_INFO
      - ARG_CORE_LIST="$core_list"
EOF
done

echo ""
echo "Stop all running containers..."
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q) 

echo ""
echo "Deploying new setup:"
docker-compose -f $docker_file_name up -d  
