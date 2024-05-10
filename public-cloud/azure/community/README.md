# Ixia-c traffic engine deployment on Azure with MANA DPDK

## Overview
This is a public cloud lab where [Ixia-c](https://github.com/open-traffic-generator/ixia-c) has two traffic ports connected within a single subnet of an Azure.
The environment is deployed using [Terraform](https://www.terraform.io/) and [Cloud-Init](https://cloud-init.io/) is used to configure the application and traffic engines.
Performance improvements are enabled through [DPDK](https://www.dpdk.org/) support.
Once the lab is up, a Python script is used to request Ixia-c to generate traffic and report statistics.

## Prerequisites

* This lab requires the commands below to be executed from within Azure CloudShell.

## Clone the repository

```
git clone -b cloud https://github.com/open-traffic-generator/otg-examples.git
```

## Navigate to the lab subdirectory within the repository

```
cd otg-examples/public-cloud/azure/community
```

## Deploy Ixia-c lab

1. Create Terraform deployment.

2. Wait approximately 6 minutes for infrastructure to be deployed.

3. Execute Python test case to generate traffic between Azure instances.

    ```
    make azure
    ```

4. Connect to Agent1 Azure VM .

    ```
    make connect
    ```

5. Set config files.

    ```
    ubuntu@agent1$ make config
    ```

## Execute Traffic Test additional times as needed

1. Execute unidirectional test case to generate traffic between Azure instances.

    ```
    ubuntu@agent1$ make run
    ```

2. Execute bidirectional test case to generate traffic between Azure instances.

    ```
    ubuntu@agent1$ make run-bidirectional
    ```

3. Execute rfc2544 test case to generate traffic between Azure instances.

    ```
    ubuntu@agent1$ make run-rfc2544
    ```

## Destroy the lab

1. Destroy the Terraform deployment

    ```
    ubuntu@agent1$ exit
    make clean
    ```
