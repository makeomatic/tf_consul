#cloud-config

runcmd:
  - "curl -V && ( curl -sSL https://get.docker.com/ | sh ) || :"
  - "wget -V && ( wget -qO- https://get.docker.com/ | sh ) || :"
  - "retries=5; while (! docker rm -f ecs-agent); do retries=$((retries-1)); [ $retries -eq 0 ] && break; sleep 2; done"
