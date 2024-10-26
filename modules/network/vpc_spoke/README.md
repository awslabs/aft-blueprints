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
| aws.network | >=5.0.0 |
| random | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| central\_vpc\_flow\_logs | ../flow_logs | n/a |
| local\_vpc\_flow\_logs | ../flow_logs | n/a |
| route53\_rules\_association | ../../dns/route53_rules_association | n/a |
| tgw\_vpc\_attachment | ../tgw_vpc_attachment | n/a |
| vpce | ../vpce | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_default_network_acl.default_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.default_rtb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.default_sgp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_internet_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [random_string.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_availability_zone.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zone) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.azs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.central_vpc_flow_logs_s3_bucket_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_vpc_ipam_pool.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_ipam_pool) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| associate\_dns\_rules | Should be true to associate shared Route 53 DNS rules | `bool` | `true` | no |
| availability\_zones | List of availability zones defined in the network account | `list(string)` | `[]` | no |
| create\_data\_subnets | Should be true to create public subnets and IGw in the VPC | `bool` | `false` | no |
| create\_nat\_gateway | Should be true to create a NAT Gateway the VPC | `bool` | `false` | no |
| create\_public\_subnets | Should be true to create public subnets and IGw in the VPC | `bool` | `false` | no |
| data\_subnet\_tags | Additional tags data subnets | `map(string)` | `{}` | no |
| enable\_central\_vpc\_flow\_logs | Should be true to enable centralized vpc flow logs to S3 bucket. | `bool` | `false` | no |
| enable\_dns\_hostnames | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable\_vpc\_flow\_logs | Should be true to enable vpc flow logs to a local cloudwatch log group. | `bool` | `true` | no |
| environment | Environment name. Will be used to define ipam pool and tgw route tables configuration. | `string` | n/a | yes |
| gateway\_endpoints | A list of interface endpoints | `list(string)` | `[]` | no |
| identifier | VPC identifier. If not entered, a random id will be generated. | `string` | `""` | no |
| interface\_endpoints | A list of interface endpoints | `list(string)` | `[]` | no |
| ipam\_pool\_id | IPAM pool id to get the VPc CIDR [optional, if don't want to use 'environment' to get the pool] | `string` | `null` | no |
| private\_subnet\_tags | Additional tags for private subnets | `map(string)` | `{}` | no |
| public\_subnet\_tags | Additional tags for public subnets | `map(string)` | `{}` | no |
| tags | Tags for all resources within the VPC | `map(string)` | `{}` | no |
| vpc\_cidr | The IPv4 CIDR block for the VPC. [required if vpc\_size is not informed] | `string` | `null` | no |
| vpc\_size | VPC netmask size to be allocated in IPAM [required if vpc\_cidr is not informed] | `string` | `"medium"` | no |
| vpc\_tags | Additional tags for the VPC | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| data\_subnets | List of IDs of private subnets |
| identifier | Identifier string |
| private\_subnets | List of IDs of private subnets |
| public\_subnets | List of IDs of public subnets |
| vpc\_cidr\_block | The CIDR block of the VPC |
| vpc\_id | The ID of the VPC |
<!-- END_TF_DOCS -->