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
| [aws_route53_resolver_rule_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule_association) | resource |
| [aws_route53_resolver_rules.shared_resolvers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_resolver_rules) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Define additional tags to be used by resources. | `map(any)` | `{}` | no |
| vpc\_id | Local VPC ID that will be associated with this hosted zone. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_route53\_resolver\_rules | n/a |
<!-- END_TF_DOCS -->