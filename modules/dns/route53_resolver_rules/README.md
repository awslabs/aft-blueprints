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
| [aws_ram_principal_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_route53_resolver_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule) | resource |
| [aws_route53_resolver_rule_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule_association) | resource |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resolver\_endpoint\_id | The resolver OUTBOUND endpoint ID to associate resolver rules. Required if rule\_type = FORWARD | `string` | `null` | no |
| resolver\_target\_ips | The resolver INBOUND endpoint IPs. | `list(string)` | `[]` | no |
| rules | The object with attributes for each resolver rule. Example: ```rules = { rule_name = "rr-on-aws" rule_type = "FORWARD" associate_to_vpc = false target_ips = ["10.10.0.7","10.10.128.132"] domain_name = "my-dns-zone.internal" }``` | ```map(object( { rule_name = optional(string)       # If it is omitted, the domain name will be used. rule_type = optional(string)       # SYSTEM or FORWARD. (default) resource_share_arn = optional(string)       # If it is omitted, it will be shared with the entire organization. associate_to_vpc = optional(bool)         # Whether to associate or not the rule to VPC [var.vpc_id]. (default is false) target_ips = optional(list(string)) # If it is omitted, the resolver inbound IPs will be used, only for rule_type = FORWARD. domain_name = string } ))``` | n/a | yes |
| tags | Define additional tags to be used by resources. | `map(any)` | `{}` | no |
| vpc\_id | The VPC to associate resolver rules. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->