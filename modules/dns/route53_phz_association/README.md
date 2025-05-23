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
| aws.dns | ~>5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_vpc_association_authorization.authorization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization) | resource |
| [aws_route53_zone_association.association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_route53_zone_association.phz](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_vpcs.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpcs) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| associate\_to\_central\_dns\_vpc | Associate central DNS VPC with the Private Hosted Zone | `bool` | `true` | no |
| associate\_to\_local\_vpc | Associate local VPC with the Private Hosted Zone (requires vpc\_id variable) | `bool` | `true` | no |
| phz\_id | The Private Hosted Zone ID | `string` | n/a | yes |
| vpc\_id | The VPC ID (required is associate\_to\_local\_vpc==true) | `string` | `null` | no |
| vpc\_region | The VPC region | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->