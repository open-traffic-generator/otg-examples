# SR-Linux Operational Group Scenario

## Overview

## Work-in-progress

```Shell
git clone https://github.com/srl-labs/opergroup-lab.git && cd opergroup-lab
sudo -E containerlab deploy -t opergroup.clab.yml
````

[Grafana dashboard](http://clabvm:3000/d/W19czJw7k/opergroups?orgId=1&refresh=5s)

```Shell
docker exec -it client1 iperf3 -c 192.168.100.2 -b 200K
docker exec -it client1 iperf3 -c 192.168.100.2 -b 200K -P2 -t 20
docker exec -it client1 iperf3 -c 192.168.100.2 -b 200K -P 4 -t 40
````

after the last one is started, wait 20s and then run in a separate terminal

```Shell
bash set-uplinks.sh leaf1 "{49..50}" disable
````

see grafana for impact on traffic

to restore

```Shell
bash set-uplinks.sh leaf1 "{49..50}" enable
````

## Misc

### CLI access to nodes

  ```Shell
  # leaf1
  sudo docker exec -it leaf1 sr_cli
  # leaf2
  sudo docker exec -it leaf2 sr_cli
  # leaf3
  sudo docker exec -it leaf3 sr_cli
  # leaf4
  sudo docker exec -it leaf4 sr_cli
  # spine1
  sudo docker exec -it spine1 sr_cli
  # spine2
  sudo docker exec -it spine2 sr_cli
  ````



## Credits

Original lab design: 
  * [Oper Groups with Event Handler](https://hellt.github.io/learn-srlinux-stage1/tutorials/programmability/event-handler/oper-group/oper-group-intro/)
  * [Oper Group lab github repository](https://github.com/srl-labs/opergroup-lab)
