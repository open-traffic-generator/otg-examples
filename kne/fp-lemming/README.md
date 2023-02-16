
Multipass VM

```Shell
multipass launch 20.04 -n knevm -c8 -m16G -d64G
multipass shell knevm
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential -y
sudo apt install docker.io -y
sudo usermod -aG docker $USER
logout
```

GCP Instance

```Shell
MYIP=`curl -s ifconfig.me`
MYIPSTR="$(echo $MYIP | sed 's/\./-/g')"

gcloud compute firewall-rules create otg-demo-allow-ssh-${MYIPSTR} --description="Allow tcp 22 ingress to any instance tagged as otg-demo-kne" --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:22 --source-ranges="$MYIP/32" --target-tags=otg-demo-kne

gcloud compute instances create otg-demo-kne \
--subnet=default \
--machine-type=e2-standard-16 \
--image-family=ubuntu-2004-lts \
--image-project=ubuntu-os-cloud \
--boot-disk-size=100GB \
--boot-disk-device-name=otg-demo-kne \
--tags=otg-demo-kne

gcloud compute ssh otg-demo-kne
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential docker.io -y
sudo usermod -aG docker $USER
 CR_PAT=YOUR_TOKEN
CR_USERNAME=YOUR_USERNAME
echo $CR_PAT | docker login ghcr.io -u $CR_USERNAME --password-stdin
git clone -b kne --depth 1 https://github.com/open-traffic-generator/otg-examples.git
logout
```

```Shell
gcloud compute ssh otg-demo-kne
cd otg-examples/kne/fp-lemming
LABDIR=$PWD
make all
logout
```

```Shell
gcloud compute ssh otg-demo-kne
cd otg-examples/kne/fp-lemming
LABDIR=$PWD
kne create ./lemming/integration_tests/onedut_oneotg_tests/topology.pb.txt
cd featureprofiles/feature/bgp/addpath/otg_tests/route_propagation_test
go test -v route_propagation_test.go -testbed "$LABDIR/lemming/integration_tests/onedut_oneotg_tests/testbed.pb.txt" -kne-config "$LABDIR/ate-lemming.ondatra.yaml"
logout
```

Cisco c8201

```Shell
kind load docker-image 8000e:latest --name=kne
cd ./featureprofiles/topologies/kne/
kne create cisco_ixia.textproto
```

```Shell
gcloud compute instances stop otg-demo-kne
gcloud compute instances delete otg-demo-kne
gcloud compute firewall-rules delete otg-demo-allow-ssh-${MYIPSTR}
```