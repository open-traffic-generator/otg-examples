#!/bin/bash

CONTAINERS=$(docker ps --filter "name=ixia-c" --format "{{.Names}}")
NOW="logs-"$(date +"%Y-%m-%d_%H%M%S")
mkdir -p $NOW
for CONTAINER in $CONTAINERS
do
	echo "Collecting logs for $CONTAINER"
	LOGFILE="log-$CONTAINER-$NOW.log"
	docker logs $CONTAINER > $NOW/$LOGFILE
	echo "Done collecting logs for $CONTAINER"

	if [[ "$CONTAINER" == *"ixia-c-ixhw-server"* ]]; then
  		echo "Collecting internal logs for ixia-c-ixhw-server"
		mkdir -p $NOW/hw
		docker cp $CONTAINER:/tmp/rpf_logs/ $NOW/hw
		docker cp $CONTAINER:/var/log/ $NOW/hw
  		echo "Done collecting internal logs for ixia-c-ixhw-server"
	fi
	echo ""
done
echo "Compressing the logs folder"
tar -zcvf "$NOW.tar.gz" $NOW
rm -rf $NOW
