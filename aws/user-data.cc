#cloud-config

runcmd:
  - curl -V && ( curl -sSL https://get.docker.com/ | sh )
  - wget -V && ( wget -qO- https://get.docker.com/ | sh )
  - docker rm -f ecs-agent
