#!/bin/sh
if [ "$#" -lt 1 ]; then
  echo Error: provide HTTP port as a parameter
  exit 2
else
  DPORT="$1"
fi

if [ -n "$CLAB_SSH_CONNECTION" ]; then
  DHOST=`echo $CLAB_SSH_CONNECTION | awk '{print $3}'`
else
  DHOST=$HOSTNAME
fi

if sh -c 'curl --silent --connect-timeout 1 http://169.254.169.254/ >/dev/null'; then
  # looks like we are running in a public cloud environment
  DHOST=`curl --silent --connect-timeout 3 ifconfig.me`
fi

echo "DDoS Protect Dashboard 🛡️  http://${DHOST}:${DPORT}/app/ddos-protect/html/index.html"
