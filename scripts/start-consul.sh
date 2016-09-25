#!/bin/sh

. /var/lib/stackfeed/cc/functions

# Read environment from json (uppercase var names, defaults: retries=120,
# interval 1 second).
eval $(wait_for_jsonenv -u /var/lib/terraform/consul/input.json)
export ADVERTISE_ADDRESS=$(address_num $ADVERTISE_IPNUM)

# Evalute default args and advertise address
args="${CONSUL_ARGS:--bootstrap-expect $SERVERS -join $SEED_ADDRESS}"

# Create directory for consul volume
mkdir -p /var/lib/consul

# Run consul-server container as daemon (+ restart always)
docker run -d --name=consul-server --restart=always \
    -p $CONSUL_DNSPORT:8600 -p $CONSUL_DNSPORT:8600/udp \
    -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302 -p 8302:8302/udp \
    -p 8400:8400 -p 8500:8500 \
    -v /var/lib/consul:/data \
    --log-opt='max-size=25m' --log-opt='max-file=5' \
$CONSUL_IMAGE \
    -advertise $ADVERTISE_ADDRESS $args
