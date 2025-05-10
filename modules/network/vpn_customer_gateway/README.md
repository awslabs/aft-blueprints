## Description

Creates the CGW VPN resource

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
| [aws_customer_gateway.customer_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| customer\_gateway\_bgp\_asn | For devices that support BGP, the customer gateway's BGP ASN. Default value of 65000 specifies static routing. Value should be between 64512 and 65534. | `number` | `65000` | no |
| customer\_gateway\_ip\_address | The Internet-routable IP address for the customer gateway's outside interface. The address must be static. | `string` | n/a | yes |
| customer\_gateway\_name | The name of the customer gateway. | `string` | n/a | yes |
| tags | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| customer\_gateway\_id | Customer Gateway ID |
<!-- END_TF_DOCS -->
