# Consul Terraform module

Consul Terraform module is used to bring up a consul cluster in a cloud provider.

 - **Supported cloud providers**: AWS
 - **Terraform version supported** *>=0.7.0rc3*

## Module configuration

|Variable|Description|Default|
|---|---|---|
|**servers**|Number of consul servers to bootstrap.|3|
|**image**|Docker container used to bootstrap consul server.|gliderlabs/consul-server|
|**args**|Arguments passed to consul server agent, can be used to override default configuration (ex. specifying atlas options).|`""`|
|**key_name**|Specifies cloud provider key name (**required**).|`""`|
|**key_path**|Specifies local path to the private ssh key used to connect to a cloud provider (**required**).|`""`|
|**dns_port**|Sets port (tcp/udp) where consul will listen for DNS queries.|8600|
|**advertise_interface**|Specifies an interface to publish consul container ports|*depends on provider*|

### AWS variables

|Variable|Description|Default|
|---|---|---|
|**advertise_interface**|see *[Module configuration](#module-configuration)*.|eth0|
|**cross_zone_distribution**|Distribute instances across different availability zones.|`true`|
|**AllowAPI_access_SGids**|Specifies security group ID list which will be allowed to access consul API and DNS ports.|`[]`|
|**security_group**|Security group name which is created for consul.|consul|

For full and up-date list refer to [aws defaults](https://github.com/stackfeed/tf_default_compute#aws).


## Usage

### AWS usage

First we need to set the AWS credentials via environment.
```
export AWS_ACCESS_KEY_ID="AKIxxxZUT"
export AWS_SECRET_ACCESS_KEY="HAVxxxbNL"
```

Next define the module configuration:

```
module "consul" {
  source = "github.com/stackfeed/tf_consul"
  servers = 3
  key_name = "aws_key_name"
  key_path = "~/.ssh/some_pkey_path"
  # Works fine without ATLAS, but just in case.
  # args = "-atlas USERNAME/PROJECT -atlas-token ATLAS_TOKEN"
}
```

Note that `args` is optional and can be omitted in this case a consul cluster will be brought up with `-bootstrap-expect 3`.

# Authors

- Denis Baryshev (<dennybaa@gmail.com>)
