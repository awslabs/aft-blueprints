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
| [aws_security_group.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_security_group_egress_rule.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_cidr | Additional CIDRs to be added in the interface endpoints security group created by the module (when security\_group\_id is not informed). | `list(string)` | `[]` | no |
| gateway\_endpoints | A list of route tables and gateway endpoints | ```object({ route_table_ids = list(string) services = list(string) })``` | ```{ "route_table_ids": [], "services": [] }``` | no |
| interface\_endpoints | A list of subnet IDs and interface endpoint service names. For service names use com.amazonaws.<region>.<service> format, or just <service> (e.g. com.amazonaws.us-east-1.ssm or ssm). | ```object({ subnet_ids = list(string) services = list(string) })``` | ```{ "services": [], "subnet_ids": [] }``` | no |
| policies | A map with endpoint service name (key) and IAM resource policy JSON (value) to be applied to endpoint. For service names use com.amazonaws.<region>.<service> format, or just <service> (e.g. com.amazonaws.us-east-1.ssm or ssm). | `map(any)` | `{}` | no |
| private\_dns\_enabled | Whether or not to enable private DNS. | `bool` | `true` | no |
| security\_group\_id | The ID of the security group to be added in the interface endpoints. | `string` | `null` | no |
| tags | Tags to be applied to all resources. | `map(string)` | `{}` | no |
| vpc\_cidr | The CIDR of the VPC in which the endpoint will be used. This CIDR will be added to the interface endpoints security group created by the module (when security\_group\_id is not informed). | `string` | `null` | no |
| vpc\_id | The ID of the VPC in which the endpoint will be used. | `string` | n/a | yes |
| vpc\_name | The name of the VPC in which the endpoint will be used. | `string` | `"vpc"` | no |
| vpc\_region | The region of the VPC in which the endpoint will be used. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| security\_group\_id | The ID of the security group |
<!-- END_TF_DOCS -->