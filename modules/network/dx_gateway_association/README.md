<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=1.5.0 |
| aws | >=5.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >=5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dx_gateway_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dx_gateway_association) | resource |
| [aws_ec2_tag.vpc_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_ec2_transit_gateway_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_dx_gateway_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway_dx_gateway_attachment) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_prefixes | List of allowed prefixes. | `list(string)` | `[]` | no |
| associated\_gateway\_id | Gateway ID to be associated to DX Gateway. | `string` | `""` | no |
| dx\_gateway\_id | DX Gateway ID. | `string` | `""` | no |
| tgw\_rt\_association | Transit Gateway route table ID to be associated with the DX GW attachment. | `string` | n/a | yes |
| tgw\_rt\_propagations | Transit Gateway route table IDs to propagate routes based DX GW BGP configuration. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| attachment\_id | n/a |
<!-- END_TF_DOCS -->