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

echo "DDoS Protect Dashboard 🛡️  http://${DHOST}:${DPORT}/app/ddos-protect/html/index.html"
