#cloud-config

runcmd:
  - "curl -V && ( curl -sSL https://get.docker.com/ | sh ) || :"
  - "wget -V && ( wget -qO- https://get.docker.com/ | sh ) || :"
  - "while (! docker version 2>/dev/null); do sleep 1; done && docker rm -f ecs-agent || :"
