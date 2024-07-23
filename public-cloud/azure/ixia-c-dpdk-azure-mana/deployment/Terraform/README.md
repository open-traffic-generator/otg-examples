# Ixia-c-on-Azure-Boost-2-Agents-1-Vnet-1-Public-Subnet-1-Private-Subnet
## Description
This deployment creates a topology with a single virtual network having a single public facing subnet and a single private subnet.

## Optional Variables
```
terraform.optional.auto.tfvars
```
You **MAY** uncomment one or more lines as needed in this file and replace values to match your particular environment.

## Required Usage
```
make all
make clean
```

## Optional Usage
```
make init
make plan
make apply
make destroy
```