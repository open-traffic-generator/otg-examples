# Open Traffic Generator examples

[![CI](https://github.com/open-traffic-generator/otg-examples/actions/workflows/ci.yml/badge.svg)](https://github.com/open-traffic-generator/otg-examples/actions/workflows/ci.yml)

## Overview

[OTG examples](https://github.com/open-traffic-generator/otg-examples) repository is a great way to get started with [Open Traffic Generator API](https://otg.dev). It features a collection of software-only network labs ranging from very simple to more complex. To setup network labs in software we use containerized or virtualized NOS images.

## OTG Tools

There are several [implementations](https://otg.dev/implementations/) of OTG API. All the labs in this repository use [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) with different types of test ports:

* [Ixia-c](https://otg.dev/implementations/#ixia-c): Ixia-c containerized software Traffic Engine (TE) and Protocol Engine (PE)
* [Ixia-c-one](https://github.com/open-traffic-generator/ixia-c/blob/main/docs/deployments.md#deploy-ixia-c-one-using-containerlab): a single-container package of Ixia-c for Containerlab
* [IxOS Hardware](https://www.keysight.com/us/en/products/network-test/network-test-hardware.html): Keysight Elastic Network Generator with Keysight/Ixia L23 Network Test Hardware

## Device Under Test

Many network vendors provide versions of their Network Operating Systems as a CNF or VNF. To make OTG Examples available for a widest range of users, our labs use open-source or freely available NOSes like [FRR](https://frrouting.org/). Replacing FRR with a container from a different vendor is a matter of modifying one of the lab examples.

Some examples don't have any DUT and use back-2-back connections between Test Ports. These are quite useful to make sure the Traffic Generator part works just fine by itself, before introducing a DUT.

## OTG Client

A job of an OTG Client is to communicating with a Traffic Generator via the OTG API and request it to perform tasks such as applying a configuration, starting protocols, running traffic, collecting metrics. Each example uses one (or sometimes more) of the following OTG Clients:

* [`curl`](https://otg.dev/clients/curl/) - The most basic utility for any kind of REST API calls, including OTG
* [`otgen`](https://otg.dev/clients/otgen/) - This command-line utility comes as part of OTG toolkit. It is capable of manipulating a wide range of OTG features while hiding a lot of complexity from a user
* [`snappi`](https://otg.dev/clients/snappi/) - Test scripts written in `snappi`, an auto-generated Python module, can be executed against any traffic generator conforming to the Open Traffic Generator API.
* [`gosnappi`](https://otg.dev/clients/gosnappi/) - Similar to `snappi`, test scripts written in `gosnappi`, an auto-generated Go module, can be executed against any traffic generator conforming to the Open Traffic Generator API.
* [`ondatra`](https://github.com/openconfig/ondatra) – Ondatra is a framework for writing and running tests against both real and containerized network devices. When executing a test via the Open Traffic Generator API, it uses `gosnappi` client library internally.

## Infrastructure

To manage deployment of the example labs, we use one of the following tools:

* [Docker Compose](https://docs.docker.com/compose/) - general-purpose tool for defining and running multi-container Docker applications
* [Containerlab](https://containerlab.dev/) - simple yet powerful specialized tool for orchestrating and managing container-based networking labs
* [Ixia-c Operator](https://github.com/open-traffic-generator/ixia-c-operator) – Ixia-c deployment orchestration engine compatible with K8s/KNE as well as Docker for Hybrid mode
* [OpenConfig KNE](https://github.com/openconfig/kne) – Kubernetes Network Emulation, which is a Google initiative to develop tooling for quickly setting up topologies of containers running various device OSes.

## CI with Github Actions

Most of the lab examples include Github Action workflow for executing OTG tests on any changes to the lab code. This could serve as a template for your CI workflow.

## Reference

| Lab                                                                                                                          | OTG Tool     | DUT  | Client               | Infrastructure  | CI  |
| ---------------------------------------------------------------------------------------------------------------------------- | ------------ | ---- | -------------------- | --------------  | --- |
| [B2B Ixia-c Traffic](https://github.com/open-traffic-generator/otg-examples/blob/main/docker-compose/b2b)                    | Ixia-c TE    | B2B  | `otgen` & `snappi`   | Compose         | yes |
| [Static B2B LAG](https://github.com/open-traffic-generator/otg-examples/blob/main/clab/ixia-c-b2b-lag)                       | Ixia-c TE    | B2B  | `otgen`              | Containerlab    | yes |
| [FRR Ixia-c Traffic](https://github.com/open-traffic-generator/otg-examples/blob/main/clab/ixia-c-te-frr)                    | Ixia-c TE    | FRR  | `otgen`              | Containerlab    | yes |
| [3xB2B Ixia-c Traffic](https://github.com/open-traffic-generator/otg-examples/blob/main/docker-compose/b2b-3pair)            | Ixia-c TE    | B2B  | `otgen`              | Compose         | yes |
| [B2B Ixia-c BGP and traffic](https://github.com/open-traffic-generator/otg-examples/blob/main/docker-compose/cpdp-b2b)       | Ixia-c PE+TE | B2B  | `gosnappi`           | Compose         | yes |
| [FRR Ixia-c ARP, BGP and traffic](https://github.com/open-traffic-generator/otg-examples/blob/main/docker-compose/cpdp-frr)  | Ixia-c PE+TE | FRR  | `curl` & `otgen`     | Compose & Clab  | yes |
| [Hello, snappi! Welcome to the Clab!](https://github.com/open-traffic-generator/otg-examples/blob/main/clab/ixia-c-b2b)      | Ixia-c-one   | B2B  | `snappi`             | Containerlab    | yes |
| [Dear snappi, please meet Scapy!](https://github.com/open-traffic-generator/otg-examples/blob/main/clab/ixia-c-b2b/SCAPY.md) | Ixia-c-one   | B2B  | `scapy` & `snappi`   | Containerlab    | yes |
| [RTBH](https://github.com/open-traffic-generator/otg-examples/blob/main/clab/rtbh)                                           | Ixia-c-one   | FRR  | `gosnappi`           | Containerlab    | yes |
| [FeatureProfiles in Hybrid mode](https://github.com/open-traffic-generator/otg-examples/blob/main/hybrid/fp-b2b)             | Ixia-c PE+TE | B2B  | `ondatra`            | KENG Operator   | yes |
| [B2B IxOS Hardware](https://github.com/open-traffic-generator/otg-examples/blob/main/hw/ixhw-b2b)                            | IxOS Hardware| B2B  | `snappi` & `ondatra` | Compose         | no  |
| [cEOS BGP and Traffic in KNE](https://github.com/open-traffic-generator/otg-examples/blob/main/kne/bgp-ceos)                 | Ixia-c PE+TE | cEOS | `otgen`              | KNE             | no  |
| [AWS DPDK Ixia-c Traffic](https://github.com/open-traffic-generator/otg-examples/blob/main/public-cloud/aws/ixia-c-dpdk-aws) | Ixia-c TE    | AWS  | `snappi`             | Terraform & Compose | no  |


## Lab Descriptions

### [B2B Ixia-c Traffic](docker-compose/b2b)

Ixia-c traffic engine back-to-back setup with Docker Compose. Fast and easy way to get started using [`otgen`](https://github.com/open-traffic-generator/otgen) CLI tool.

### [Static B2B LAG](clab/ixia-c-b2b-lag)

Two Ixia-c Traffic Engines connected back-2-back in a Containerlab environment over two pairs of ports in a LAG. The goal is to demonstrate how to create a static Link Aggregation Group (LAG) consisting of two ports and run traffic over the LAG interface.

### [FRR Ixia-c Traffic](clab/ixia-c-te-frr)

Ixia-c Traffic Engine and FRR. Demonstrates how to deploy Ixia-c Traffic Engine nodes in Containerlab. This setup has an FRR container as a Device Under Test.

### [3xB2B Ixia-c Traffic](docker-compose/b2b-3pair)

Ixia-c 3 back-to-back pairs setup with Docker Compose. This lab is an extension of [Ixia-c back-2-back lab](docker-compose/b2b/README.md) traffic engine setup with more port pairs that is allowed with free version of Ixia-c. Use this lab to validate Ixia-c commercial licensing for basic traffic operations.

### [B2B Ixia-c BGP and traffic](docker-compose/cpdp-b2b)

Ixia-c back-to-back BGP and traffic setup with Docker Compose. This is an extended version of a basic [Ixia-c back-2-back lab](docker-compose/b2b/README.md) with Ixia-c Protocol Engine added to emulate L2-3 protocols like BGP.

### [Ixia-c KENG ARP, BGP and traffic](docker-compose/cpdp-frr)

Ixia-c ARP, BGP and traffic with FRR as a DUT. This lab demonstrates validation of an FRR DUT for basic BGP peering, prefix announcements and passing of traffic between announced subnets. The lab has two alternative deployment methods: Compose as well as Containerlab.

### [Hello, snappi! Welcome to the Clab!](clab/ixia-c-b2b)

Basics of creating a Python program to control Ixia-c-one node, all packaged in a Containerlab topology.

### [Dear snappi, please meet Scapy!](clab/ixia-c-b2b/SCAPY.md)

Joint use of Scapy packet crafting Python module with snappi, to generate custom DNS flows via Ixia-c-one node.

### [RTBH](clab/rtbh)

Remote Triggered Black Hole (RTBH) is a common DDoS mitigation technique which uses BGP announcements to request an ISP to drop all traffic to an IP address under a DDoS attack.

### [FeatureProfiles in Hybrid mode](hybrid/fp-b2b)

An introduction to [OpenConfig](https://openconfig.net/) [FeatureProfiles](https://github.com/openconfig/featureprofiles) test suites built with the [Open Traffic Generator API](https://otg.dev).

### [OTG with Ixia L23 Hardware: back-to-back setup](hw/ixhw-b2b)

Demonstration of how the OTG API can be used to control [Keysight/Ixia L23 Network Test Hardware](https://www.keysight.com/us/en/products/network-test/network-test-hardware.html), including an example of running [OpenConfig](https://openconfig.net/) [FeatureProfiles](https://github.com/openconfig/featureprofiles) test suites.

### [KNE Lab with BGP and traffic via Arista cEOSLab as a DUT](kne/bgp-ceos)

Validation of Arista cEOSLab DUT for basic BGP peering, prefix announcements and passing of traffic between announced subnets. To run OTG protocols and flows, [Keysight Elastic Network Generator](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) Community Edition is used with Ixia-c Traffic and Protocol Engine ports. To run the lab, [OpenConfig KNE](https://github.com/openconfig/kne) is used on top of a KIND cluster – K8s environment running inside a single Docker container.

### [Ixia-c traffic engine deployment on Amazon Web Services with DPDK](public-cloud/aws/ixia-c-dpdk-aws)

An AWS deployment where [Ixia-c](https://ixia-c.dev) has two traffic ports connected within a single VPC subnet. Performance improvements are enabled through [DPDK](https://www.dpdk.org/) support.
