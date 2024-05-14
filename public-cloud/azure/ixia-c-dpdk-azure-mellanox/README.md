# KENG-on-Azure-Boost-2-Agents-2-Eth-1-Vnet-1-Public-Subnet-1-Private-Subnet

## Description
This deployment creates a topology with a single virtual network having a single public facing subnet and a single private subnet.

## Prerequisites
* This lab requires the commands below to be executed from within Azure CloudShell.
* The created VMs needs to have at least ConnectX4 or ConnectX5. Mellanox ConnectX3 is not longer supported.    
  Use the `lspci` command to check NIC type.   
E.g.
```
ubuntu@terraform-v8KJ8A-azure-community-mellanox-agent1-instance:~$ lspci
8ada:00:02.0 Ethernet controller: Mellanox Technologies MT27710 Family [ConnectX-4 Lx Virtual Function] (rev 80)
```

## Authentication Variables
```
terraform.hcp.auto.tfvars
```
You **MUST** uncomment all lines in this file and replace values to match your particular environment.  
Otherwise, Terraform will prompt the user to supply input arguents via cli.

## Required Variables
```
terraform.required.auto.tfvars
```
You **MUST** uncomment all lines in this file and replace values to match your particular environment.  
Otherwise, Terraform will prompt the user to supply input arguents via cli.

## Optional Variables
```
terraform.optional.auto.tfvars
```
You **MAY** uncomment one or more lines as needed in this file and replace values to match your particular environment.

## Required Usage
```
terraform init
terraform apply -auto-approve
terraform destroy -auto-approve
terraform output SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" > SshKey.pem
Agent1DnsName=$(terraform output | grep agent1 | sed -n 's/.*=.//p' | tr -d '"')
```

## Optional Usage
```
terraform validate
terraform plan
terraform state list
terraform output
```

## KENG Sample Usage
```
chmod 400 SshKey.pem
ssh -i SshKey.pem ubuntu@$Agent1DnsName
$ source ./venv/bin/activate
$ cd keng-python
$ docker ps
$ ./unidirectional.sh -s 4100
 ```
