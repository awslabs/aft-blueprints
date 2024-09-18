<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=1.5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | 5.44.0 |
| aws.aft-management | 5.44.0 |
| aws.org-management | 5.44.0 |
| aws.primary | 5.44.0 |
| aws.secondary | 5.44.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aft\_custom\_fields | ../../common/modules/custom_fields | n/a |
| dx\_gateway | ../../common/modules/network/dx_gateway | n/a |
| ipam | aws-ia/ipam/aws | 2.1.0 |
| main\_phz | ../../common/modules/dns/route53_phz | n/a |
| primary\_dx\_gw\_association | ../../common/modules/network/dx_gateway_association | n/a |
| primary\_region | ./modules/region | n/a |
| primary\_tgw\_peering\_routing | ../../common/modules/network/tgw_routing | n/a |
| secondary\_dx\_gw\_association | ../../common/modules/network/dx_gateway_association | n/a |
| secondary\_region | ./modules/region | n/a |
| secondary\_tgw\_peering\_routing | ../../common/modules/network/tgw_routing | n/a |
| tgw\_peering\_primary\_to\_secondary | ../../common/modules/network/tgw_peering | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ram_sharing_with_organization.ram](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_sharing_with_organization) | resource |
| [aws_ssm_parameter.account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_vpc_ipam_organization_admin_account.ipam](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_organization_admin_account) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_region.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_availability\_zones | "Map of availability zones allowed to be used in this region." Example: ```aws_availability_zones = { primary_region = { az1 = "us-east-1a" az2 = "us-east-1b" } secondary_region = { az1 = "us-west-2a" az2 = "us-west-2b" } }``` | `map(any)` | n/a | yes |
| aws\_dx\_info | "Object with Direct Connect information to be used in AWS regions." Example: ```{ gateway_name = "aws-dx-gateway" bgp_asn = "64550" }``` | `map(string)` | n/a | yes |
| aws\_ip\_address\_plan | "Object with IP address plan which defines the CIDR blocks to be used in AWS regions." Example: ```aws_ip_address_plan = { global_cidr_blocks = ["10.10.0.0/16","10.20.0.0/16"] primary_region = { cidr_blocks = ["10.10.0.0/16"] shared = { cidr_blocks = ["10.10.0.0/18"] } prod = { cidr_blocks = ["10.10.64.0/18"] } stage = { cidr_blocks = ["10.10.128.0/18"] } dev = { cidr_blocks = ["10.10.192.0/18"] } } secondary_region = { cidr_blocks = ["10.20.0.0/16"] shared = { cidr_blocks = ["10.20.0.0/18"] } prod = { cidr_blocks = ["10.20.64.0/18"] } stage = { cidr_blocks = ["10.20.128.0/18"] } dev = { cidr_blocks = ["10.20.192.0/18"] } } }``` | ```object({ global_cidr_blocks = list(string) primary_region = object({ cidr_blocks = list(string) shared = object({ cidr_blocks = list(string) }) prod = object({ cidr_blocks = list(string) }) stage = object({ cidr_blocks = list(string) }) dev = object({ cidr_blocks = list(string) }) }) secondary_region = optional(object({ cidr_blocks = list(string) shared = object({ cidr_blocks = list(string) }) prod = object({ cidr_blocks = list(string) }) stage = object({ cidr_blocks = list(string) }) dev = object({ cidr_blocks = list(string) }) })) })``` | n/a | yes |
| aws\_vpn\_info | "Object with VPN information to be used in AWS regions." Example: ```primary_region = { customer_gateway_name = "my_cgw" customer_gateway_ip_address = "1.1.1.1" customer_gateway_bgp_asn = 64521 static_routes_only = false local_ipv4_network_cidr = "192.168.0.0/16" remote_ipv4_network_cidr = "10.0.0.0/8" } secondary_region = { customer_gateway_name = "my_cgw" customer_gateway_ip_address = "2.2.2.2" customer_gateway_bgp_asn = 64522 static_routes_only = false local_ipv4_network_cidr = "192.168.0.0/16" remote_ipv4_network_cidr = "10.0.0.0/8" } }``` | `map(any)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->