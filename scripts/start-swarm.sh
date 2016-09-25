#!/bin/sh
# This scripts starts docker swarm manager in replication manager.
#

. /var/lib/stackfeed/cc/functions

# Export env from json
eval $(wait_for_jsonenv -u -e /var/lib/terraform/consul/input.json)
export ADVERTISE_ADDRESS=$(address_num $ADVERTISE_IPNUM)

# Do not start swarm if not asked to
[ "$SWARM_ENABLED" -eq 0 ] && exit 0

docker run -d --name=swarm-server --restart=always \
    -p $SWARM_MANAGERPORT:3375 \
$SWARM_IMAGE \
    manage -H :3375 --replication \
    --advertise $ADVERTISE_ADDRESS:$SWARM_MANAGERPORT consul://$ADVERTISE_ADDRESS:8500
