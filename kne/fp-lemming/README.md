
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
MYIP=`curl ifconfig.me`
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
sudo apt install build-essential -y
sudo apt install docker.io -y
sudo usermod -aG docker $USER
logout
```

```Shell
gcloud compute instances delete otg-demo-kne
gcloud compute firewall-rules delete otg-demo-allow-ssh-${MYIPSTR}
```