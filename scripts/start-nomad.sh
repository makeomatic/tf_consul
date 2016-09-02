#!/bin/sh

. /var/lib/stackfeed/cc/functions

confname=nomad.conf.hcl
confdir=/etc/nomad
template=/var/lib/terraform/consul/$confname.tmpl

# Export env from json
eval $(wait_for_jsonenv -u -e /var/lib/terraform/consul/input.json)
export ADVERTISE_ADDRESS=$(address_num $ADVERTISE_IPNUM)

# Do not start nomad if not asked to
[ "$NOMAD_ENABLED" -eq 0 ] && exit 0

# Create etc and a volume directory for nomad
mkdir -p $confdir /var/lib/nomad

# Generate config and run nomad container as daemon (+ restart always)
dockerize -template $template:$confdir/$confname

docker run -d --name=nomad-server --restart=always \
    -p 4646:4646 -p 4647:4647 -p 4648:4648 -p 4648:4648/udp \
    -v $confdir:/config -v /var/lib/nomad:/data \
    --log-opt='max-size=25m' --log-opt='max-file=5' \
$NOMAD_IMAGE
