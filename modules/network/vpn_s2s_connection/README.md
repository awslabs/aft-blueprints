## Description

Creates the VPN resource connected to the TGW

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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_tag.vpn_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_ec2_transit_gateway_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_vpn_connection.vpn_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_id | Account ID | `string` | n/a | yes |
| connection\_name | The name of the VPN connection | `string` | n/a | yes |
| customer\_gateway\_id | The Customer gateway ID | `string` | n/a | yes |
| local\_ipv4\_network\_cidr | The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection. | `string` | `"0.0.0.0/0"` | no |
| remote\_ipv4\_network\_cidr | The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection. | `string` | `"0.0.0.0/0"` | no |
| static\_routes\_only | Whether the VPN connection uses static routes exclusively. | `bool` | `false` | no |
| tags | n/a | `map(string)` | `{}` | no |
| tgw\_rt\_association | Transit Gateway route table ID to be associated with the VPN attachment. | `string` | n/a | yes |
| tgw\_rt\_propagations | Transit Gateway route table IDs to propagate routes based VPN BGP configuration. | `map(string)` | n/a | yes |
| transit\_gateway\_id | The Transit Gateway ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| transit\_gateway\_attachment\_id | TGW Attachment ID |
| vpn\_connection\_id | VPN Connection ID |
<!-- END_TF_DOCS -->
