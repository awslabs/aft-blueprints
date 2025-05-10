<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=1.5.0 |
| aws | ~>5.0 |

## Providers

| Name | Version |
|------|---------|
| aws.peer-accepter | ~>5.0 |
| aws.peer-requester | ~>5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_peering_attachment.requester](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_peering_attachment_accepter.accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment_accepter) | resource |
| [aws_ec2_transit_gateway_route_table_association.accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.requester](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Define additional tags to be used by resources. | `map(string)` | `{}` | no |
| tgw\_accepter\_account\_id | Accepter Transit Gateway ID | `string` | `null` | no |
| tgw\_accepter\_id | Accepter Transit Gateway ID | `string` | n/a | yes |
| tgw\_accepter\_region | Accepter Transit Gateway region | `string` | n/a | yes |
| tgw\_accepter\_route\_table\_id | Accepter Transit Gateway route table ID to associate the peering attachment | `string` | n/a | yes |
| tgw\_requester\_id | Requester Transit Gateway ID | `string` | n/a | yes |
| tgw\_requester\_region | Requester Transit Gateway region | `string` | n/a | yes |
| tgw\_requester\_route\_table\_id | Requester Transit Gateway route table ID to associate the peering attachment | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| tgw\_attachment\_id | Transit Gateway Attachment Id |
<!-- END_TF_DOCS -->