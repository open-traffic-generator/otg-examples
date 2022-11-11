# Open Traffic Generator examples
[![CI](https://github.com/open-traffic-generator/otg-examples/actions/workflows/ci.yml/badge.svg)](https://github.com/open-traffic-generator/otg-examples/actions/workflows/ci.yml)

## Overview 

[OTG examples](https://github.com/open-traffic-generator/otg-examples) repository is a great way to get started. It features a collection of software-only network labs ranging from very simple to more complex. To setup network labs in software we use containerized or virtualized NOS images.

## OTG Tools

There are several implementations of OTG API. Each example uses one of the following:

* [Ixia-c TE](https://otg.dev/implementations/#ixia-c): Ixia-c Traffic Engine
* [Ixia-c-one](https://github.com/open-traffic-generator/ixia-c/blob/main/docs/deployments.md#deploy-ixia-c-one-using-containerlab): a single-container package of Ixia-c Traffic Engine for Containerlab
* [KENG TE](https://otg.dev/implementations/#keng): Keysight Elastic Network Generator – Traffic Engine
* [KENG TE+PE](https://otg.dev/implementations/#keng): Keysight Elastic Network Generator – Traffic and Protocol Engines

## Device Under Test

Many network vendors provide versions of their Network Operating Systems as a CNF or VNF. To make OTG Examples available for a widest range of users, our labs use open-source or freely available NOSes like [FRR](https://frrouting.org/). Replacing FRR with a container from a different vendor is a matter of modifying one of the lab examples.

Some examples don't have any DUT and use back-2-back connections between Test Ports. These are quite useful to make sure the Traffic Generator part works just fine by itself, before introducing a DUT.

## Infrastructure

To manage deployment of the example labs, we use one of the following declarative tools:

* [Docker Compose](https://docs.docker.com/compose/) - general-purpose tool for defining and running multi-container Docker applications
* [Containerlab](https://containerlab.dev/) - simple yet powerful specialized tool for orchestrating and managing container-based networking labs

## CI with Github Actions

Some of the lab examples include Github Action workflow for executing OTG tests on any changes to the lab code. This could serve as a template for your CI workflow.

## Reference

| Lab                                                                                                                       | OTG Tool    | DUT  | Client     | Infrastructure | CI  |
| ------------------------------------------------------------------------------------------------------------------------- | ----------- | ---- | ---------- | -------------- | --- |
| [Ixia-c traffic engine](https://github.com/open-traffic-generator/otg-examples/blob/main/docker-compose/b2b)              | Ixia-c TE   | B2B  | [`otgen`](../clients/otgen.md)    | Compose        | yes |
| [KENG 3 pairs](https://github.com/open-traffic-generator/otg-examples/blob/main/docker-compose/b2b-3pair)                 | KENG TE     | B2B  | [`otgen`](../clients/otgen.md)    | Compose        | yes  |
| [KENG BGP and traffic](https://github.com/open-traffic-generator/otg-examples/blob/main/docker-compose/cpdp-b2b)          | KENG PE+TE  | B2B  | [`gosnappi`](../clients/gosnappi.md) | Compose        | yes |
| [FRR+KENG ARP, BGP and traffic](https://github.com/open-traffic-generator/otg-examples/blob/main/docker-compose/cpdp-frr) | KENG PE+TE  | FRR  | [`curl`](../clients/curl.md) | Compose        | yes |
| [Hello, snappi! Welcome to the Clab!](https://github.com/open-traffic-generator/otg-examples/blob/main/clab/ixia-c-b2b)   | Ixia-c-one  | B2B  | [`snappi`](../clients/snappi.md)   | Containerlab   | no  |
| [Ixia-c-one and FRR](https://github.com/open-traffic-generator/otg-examples/blob/main/clab/ixia-c-te-frr)                 | Ixia-c TE   | FRR  | [`otgen`](../clients/otgen.md)    | Containerlab   | no  |
| [Remote Triggered Black Hole](https://github.com/open-traffic-generator/otg-examples/blob/main/clab/rtbh)                 | Ixia-c-one  | FRR  | [`gosnappi`](../clients/gosnappi.md) | Containerlab   | yes |


## Quick Lab Descriptions

### [Ixia-c traffic engine back-to-back setup with Docker Compose](docker-compose/b2b)

Fast and easy way to get started using [`otgen`](https://github.com/open-traffic-generator/otgen) CLI tool.

### [KENG 3 back-to-back pairs setup with Docker Compose](docker-compose/b2b-3pair)
This lab is an extension of [Ixia-c back-2-back lab](docker-compose/b2b/README.md) traffic engine setup with more port pairs that is allowed with free version of Ixia-c. Use this lab to validate Ixia-c commercial version – KENG for basic traffic operations.

### [KENG back-to-back BGP and traffic setup with Docker Compose](docker-compose/cpdp-b2b)

This is an extended version of a basic [Ixia-c back-2-back lab](docker-compose/b2b/README.md) with [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) components added to emulate L2-3 protocols like BGP.

### [KENG ARP, BGP and traffic with FRR as a DUT](docker-compose/cpdp-frr)

This lab demonstrates validation of an FRR DUT for basic BGP peering, prefix announcements and passing of traffic between announced subnets.

### [Ixia-c Traffic Engine and FRR](/clab/ixia-c-te-frr)

Demonstrates how to deploy Ixia-c Traffic Engine nodes in Containerlab. This setup has an FRR container as a Device Under Test.

### [Hello, snappi! Welcome to the Clab!](/clab/ixia-c-b2b) 

Basics of creating a Python program to control Ixia-c-one node, all packaged in a Containerlab topology.

### [KENG ARP, BGP and traffic with FRR as a DUT](docker-compose/cpdp-frr) 

This lab demonstrates validation of an FRR DUT for basic BGP peering, prefix announcements and passing of traffic between announced subnets. Same lab as in basic examples section, but with Containerlab. 

### [Remote Triggered Black Hole Lab](/clab/rtbh) (RTBH) 

RTBH is a common DDoS mitigation technique which uses BGP announcements to request an ISP to drop all traffic to an IP address under a DDoS attack.

## Useful links

[//]: # (TODO add source tracking to the links)

* Vendor-neutral [Open Traffic Generator](https://github.com/open-traffic-generator) model and API
* [Ixia-c](https://github.com/open-traffic-generator/ixia-c), a powerful traffic generator based on Open Traffic Generator API
* [`otgen`](https://github.com/open-traffic-generator/otgen) command line client tool to communicate with OTG-compliant traffic generators
* [Ixia-c Slack support channel](https://github.com/open-traffic-generator/ixia-c/blob/main/docs/support.md)
* [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html), a commercial version of Ixia-c with L3 protocol engine, no restrictions on performance and scalability, priority technical support.
* [Containerlab](https://containerlab.dev/), a CLI for orchestrating and managing container-based networking labs.
