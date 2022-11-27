#!/bin/sh

export OTG_LOCATION_P1="localhost:5555+localhost:50071"
export OTG_LOCATION_P2="localhost:5556+localhost:50072"

otgen create device -n ce1111 --ip 192.0.2.2 --gw 192.0.2.1 --prefix 30 -p p1 | \
otgen add bgp -d ce1111 --asn 1111 --peer 192.0.2.1 --route 1.1.1.1/32 | \
otgen add device -n ce2222 --ip 203.0.113.2 --gw 203.0.113.1 --prefix 30  -p p2 | \
otgen add bgp -d ce2222 --asn 2222 --peer 203.0.113.1 --route 2.2.2.2/32 | \
otgen add flow -n f1 --tx ce1111 --rx ce2222 --dmac auto --src 1.1.1.1 --dst 2.2.2.2 --rate 100 --count 1000 --size 512 | \
otgen add flow -n f2 --tx ce2222 --rx ce1111 --dmac auto --dst 1.1.1.1 --src 2.2.2.2 --rate 100 --count 1000 --size 512 | \
otgen --log debug run --insecure --metrics flow | otgen transform --metrics flow | otgen display -m table
