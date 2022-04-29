# Remote Triggered Blackhole Scenario

## Launch with ContainerLab

sudo -E containerlab deploy -t rtbh.yml

### CLI access to nodes

```Shell
docker exec -it clab-rtbh-pe-router vtysh
docker exec -it clab-rtbh-ce-router vtysh

docker exec -it clab-rtbh-attacker sh
docker exec -it clab-rtbh-victim sh
````
