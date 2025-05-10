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
| [aws_route53_resolver_endpoint.inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_endpoint) | resource |
| [aws_route53_resolver_endpoint.outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_endpoint) | resource |
| [aws_security_group.inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_route53_resolver_endpoint.inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_resolver_endpoint) | data source |
| [aws_route53_resolver_endpoint.outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_resolver_endpoint) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| rfc1918\_cidr | List of private address cidrs. | `list(string)` | ```[ "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16" ]``` | no |
| route53\_resolver\_name | The name for your resolver endpoint. The module will append '-inbound' or '-outbound' to the name. | `string` | `"resolver-endpoint"` | no |
| route53\_resolver\_subnet\_ids | List of subnet ids to be used by resolver to create a interface endpoint. | `list(string)` | `null` | no |
| tags | Define additional tags to be used by resources. | `map(any)` | `{}` | no |
| vpc\_id | The VPC to associate with resolver endpoint. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| inbound\_endpoint\_id | n/a |
| inbound\_endpoint\_ips | n/a |
| outbound\_endpoint\_id | n/a |
| outbound\_endpoint\_ips | n/a |
<!-- END_TF_DOCS -->