# Open Traffic Generator examples

## Basic examples

* [Ixia-c traffic engine back-to-back setup with Docker Compose](docker-compose/b2b). Fast and easy way to get started using [`otgen`](https://github.com/open-traffic-generator/otgen) CLI tool.
* [KENG back-to-back setup with Docker Compose](docker-compose/cpdp-b2b). This is an extended version of a basic [Ixia-c back-2-back lab](docker-compose/b2b/README.md) with [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) components added to emulate L2-3 protocols like BGP.

## Scenarios with Containerlab

* [Hello, snappi! Welcome to the Clab!](/clab/ixia-c-b2b) – basics of creating a Python program to control Ixia-c, all packaged in a Containerlab topology.
* [Remote Triggered Black Hole Lab](/clab/rtbh) (RTBH) - common DDoS mitigation technique, uses BGP announcements to request an ISP to drop all traffic to an IP address under a DDoS attack.

## Useful links

[//]: # (TODO add source tracking to the links)

* Vendor-neutral [Open Traffic Generator](https://github.com/open-traffic-generator) model and API
* [Ixia-c](https://github.com/open-traffic-generator/ixia-c), a powerful traffic generator based on Open Traffic Generator API
* [`otgen`](https://github.com/open-traffic-generator/otgen) command line client tool to communicate with OTG-compliant traffic generators
* [Ixia-c Slack support channel](https://github.com/open-traffic-generator/ixia-c/blob/main/docs/support.md)
* [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html), a commercial version of Ixia-c with L3 protocol engine, no restrictions on performance and scalability, priority technical support.
* [Containerlab](https://containerlab.dev/), a CLI for orchestrating and managing container-based networking labs.
