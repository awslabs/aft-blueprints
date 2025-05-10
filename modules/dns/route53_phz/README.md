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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [random_integer.value](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| add\_vpc | List of local additional VPC (vpc\_id and region) that will be associated with this hosted zone. | ```map(object({ vpc_id = string region = string }))``` | `{}` | no |
| create\_test\_record | Whether create a test record in the private hosted zone. | `bool` | `false` | no |
| force\_destroy | Whether to destroy all records inside if the hosted zone is deleted. | `bool` | `false` | no |
| name | Name of the hosted zone. | `string` | `null` | no |
| tags | Define additional tags to be used by resources. | `map(any)` | `{}` | no |
| vpc\_id | Local VPC ID that will be associated with this hosted zone. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| zone\_id | The hosted zone id |
<!-- END_TF_DOCS -->