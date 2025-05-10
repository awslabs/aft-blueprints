<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=1.5.0 |
| aws | ~>5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~>5.0 |
| random | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| central\_vpc\_flow\_logs | ../flow_logs | n/a |
| local\_vpc\_flow\_logs | ../flow_logs | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.alert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.flow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_network_acl.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_ec2_transit_gateway_route_table_association.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_eip.ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_kms_key.nfw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.nfw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_nat_gateway.ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_networkfirewall_firewall.nfw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall) | resource |
| [aws_networkfirewall_firewall_policy.nfw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_logging_configuration.nfw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_logging_configuration) | resource |
| [aws_route.private_ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_nfw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.tgw_nfw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [random_string.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_id | Account ID | `string` | `""` | no |
| az\_set | "Map of availability zones. It overrides the variable availability\_zones" Example: ```az_set = { az1 = "us-east-1a" az2 = "us-east-1b" az3 = "us-east-1c" }``` | `map(string)` | `{}` | no |
| central\_vpc\_flow\_logs\_destination\_arn | The ARN of the resource destination to export VPC flow logs to. | `string` | `null` | no |
| enable\_central\_vpc\_flow\_logs | Should be true to enable centralized vpc flow logs to S3 bucket. | `bool` | `false` | no |
| enable\_egress | It creates public resources to allow egress traffic | `bool` | `true` | no |
| enable\_vpc\_flow\_logs | Should be true to enable vpc flow logs to a local cloudwatch log group. | `bool` | `true` | no |
| environment | Environment name. Will be used to define ipam pool and tgw route tables configuration. | `string` | `"shared"` | no |
| identifier | VPC identifier. If not entered, a random id will be generated. | `string` | `""` | no |
| ipam\_pool\_id | IPAM pool id to get the VPc CIDR [required if vpc\_cidr is not informed] | `string` | `null` | no |
| network\_firewall\_config | Map of network firewall configurations.  Available options:   - `home_net`                = Used to expand the local network definition beyond the CIDR range of the VPC where you deploy Network Firewall   - `stateless_default_actions`           = Set of actions to take on a packet if it does not match any of the stateless rules in the policy.                                             You must specify one of the standard actions including: aws:drop, aws:pass or aws:forward\_to\_sfe.   - `stateless_fragment_default_actions`  = Set of actions to take on a fragmented packet if it does not match any of the stateless rules in the policy.                                             You must specify one of the standard actions including: aws:drop, aws:pass or aws:forward\_to\_sfe.   - `flow_log`                            = Indicates whether the network firewall flow logs should be activated   - `alert_log`                           = Indicates whether the network firewall alert logs should be activated | ```object( { home_net = optional(list(string)) stateless_default_actions = optional(string) stateless_fragment_default_actions = optional(string) flow_log = optional(bool) alert_log = optional(bool) } )``` | ```{ "alert_log": true, "flow_log": true, "home_net": null, "stateless_default_actions": "aws:forward_to_sfe", "stateless_fragment_default_actions": "aws:forward_to_sfe" }``` | no |
| region\_name | VPC region name. You can use a long or short name. (This value will form the resource name) | `string` | `""` | no |
| tags | Tags for all resources within the VPC | `map(string)` | `{}` | no |
| tgw\_routes | Private network CIDR to be routed to the Transit Gateway | `list(string)` | ```[ "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16" ]``` | no |
| transit\_gateway\_id | Transit Gateway Id | `string` | n/a | yes |
| transit\_gateway\_route\_table\_id | Transit Gateway Route Table Id to associate the VPC attachment | `string` | n/a | yes |
| vpc\_cidr | VPC CIDR (minimum size /24) [required if ipam\_pool\_id is not informed] | `string` | `null` | no |
| vpc\_tags | Tags for all resources within the VPC | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| tgw\_attachment\_id | n/a |
| vpc\_id | n/a |
<!-- END_TF_DOCS -->