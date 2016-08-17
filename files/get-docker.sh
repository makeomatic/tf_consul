#!/bin/sh
# This script gets docker using curl or wget.
# It's a terraform template, don't forget to escape shell notatation as $${}.
#

# Get docker
#
(curl -V && curl -sSL https://get.docker.com/ | sh) || (wget -V && wget -qO- https://get.docker.com/ | sh)
[ $? -ne 0 ] && { >&2 echo "Couldn't install docker, maybe fetch agents curl or wget don't exist."; exit 1; }

# Wait for docker
# Totally wait for 6 seconds (30*0.2)
#
retries=30
interval=0.2

while (! docker info &>/dev/null); do
    [ $retries -eq 0 ] && break || sleep $interval
    retries=$((retries-1))
done

exit 0
