# Keysight Elastic Network Generator Image Access

## Access to private images on Github Container Registry

In order to use this method, you need a Github account. The account should be given access to private [KENG](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) images by Keysight team. Use "Request Demo" link on [KENG](https://www.keysight.com/us/en/products/network-test/protocol-load-test/keysight-elastic-network-generator.html) page for that.

Create a new personal access token (PAT) via [https://github.com/settings/tokens/new](https://github.com/settings/tokens/new?scopes=read:packages):

* Note: ghcr.io
* Expiration: 90 days
* Scope: read:packages (should be already selected if the link above was used)

Save the token in a password manager and use it for `CR_PAT` variable below. Also, don't forget to provide your github username for `CR_USERNAME`

```Shell
CR_PAT=YOUR_TOKEN
CR_USERNAME=YOUR_USERNAME
echo $CR_PAT | docker login ghcr.io -u $CR_USERNAME --password-stdin
```

Pull KENG images to validate access (note, depending on the access provided, you might need to use a different set of images):

```Shell
docker pull ghcr.io/open-traffic-generator/licensed/ixia-c-controller:0.0.1-4013
docker pull ghcr.io/open-traffic-generator/licensed/ixia-c-protocol-engine:1.00.0.299
```
