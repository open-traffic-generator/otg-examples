#!/bin/bash

NO_HUGEPAGES=4536

mkdir -p /mnt/huge
mount -t hugetlbfs nodev /mnt/huge
echo $NO_HUGEPAGES > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
NR_HUGEPAGES=$(cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages)

if [ $NR_HUGEPAGES -eq $NO_HUGEPAGES ]
then
    echo "$NR_HUGEPAGES 2MB hugepages were allocated."
    echo "OK"
else
    echo "$NR_HUGEPAGES 2MB hugepages were allocated."
fi
