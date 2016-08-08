#cloud-config

runcmd:
  - "curl -V && ( curl -sSL https://get.docker.com/ | sh ) || :"
  - "wget -V && ( wget -qO- https://get.docker.com/ | sh ) || :"
  - "sleep 5 && docker rm -f ecs-agent || :"
