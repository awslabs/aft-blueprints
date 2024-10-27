# Network Customization - Multi Region Basic

This Terraform configuration is designed to customize the network infrastructure in a multi AWS region.

The following resources will be deployed by this solution (not limited to those below):

- AWS Transit Gateway
- Amazon VPC IP Address Manager (IPAM)
- Centralized VPC Endpoints
- Centralized Egress VPC with NAT Gateway
- Centralized Endpoints VPC for Route 53 Endpoints and VPC Endpoints
- Amazon Route 53 Private Hosted Zone
- Amazon Route 53 Endpoint Resolvers and Rules

For more information, see the [Network Intermediate](https://awslabs.github.io/aft-blueprints/architectures/network-intermediate) and [Centralized DNS](https://awslabs.github.io/aft-blueprints/architectures/centralized-dns) architecture pages.

## How to use

Define the regions you want to use in the `aft-config.j2` file:

```jinja
{% 
  set regions = [
    {
      "key": "primary",
      "name": "us-east-1"
    },
    {
      "key": "secondary",
      "name": "us-west-2"
    }
  ]
%}
```

Update the `variable.auto.tfvars` file with the corresponding values for:

### Amazon VPC IP Address Manager (IPAM)

- Add the IP address plan which defines the CIDR blocks to be used in AWS regions.

Example:

```terraform
aws_ip_address_plan = {
  global_cidr_blocks = ["10.10.0.0/16","10.20.0.0/16"]
  primary_region = {
    cidr_blocks = ["10.10.0.0/16"]
    shared = {
      cidr_blocks = ["10.10.0.0/18"]
    }
    prod = {
      cidr_blocks = ["10.10.64.0/18"]
    }
    stage = {
      cidr_blocks = ["10.10.128.0/18"]
    }
    dev = {
      cidr_blocks = ["10.10.192.0/18"]
    }
  }
  secondary_region = {
    cidr_blocks = ["10.20.0.0/16"]
    shared = {
      cidr_blocks = ["10.20.0.0/18"]
    }
    prod = {
      cidr_blocks = ["10.20.64.0/18"]
    }
    stage = {
      cidr_blocks = ["10.20.128.0/18"]
    }
    dev = {
      cidr_blocks = ["10.20.192.0/18"]
    }
  }
}
```

### Choose the VPC endpoint services to be centralized

- Add each service in the ```aws_vpc_endpoint_services``` variable.

Example:

```terraform
aws_vpc_endpoint_services = [
  "ec2",
  "ec2messages",
  "ssm",
  "ssmmessages"
]
```

### Choose the Availability Zones to be used by VPCs across all accounts

- Add the availability zones allowed to be used in each region.

Example:

```terraform
aws_availability_zones = {
  primary_region = {
    az1 = "us-east-1a"
    az2 = "us-east-1b"
  }
  secondary_region = {
    az1 = "us-west-2a"
    az2 = "us-west-2b"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=1.5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | 5.73.0 |
| aws.aft-management | 5.73.0 |
| aws.org-management | 5.73.0 |
| aws.primary | 5.73.0 |
| aws.secondary | 5.73.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aft\_custom\_fields | ../../common/modules/custom_fields | n/a |
| ipam | aws-ia/ipam/aws | 2.1.0 |
| main\_phz | ../../common/modules/dns/route53_phz | n/a |
| primary\_region | ./modules/region | n/a |
| primary\_tgw\_peering\_routing | ../../common/modules/network/tgw_routing | n/a |
| secondary\_region | ./modules/region | n/a |
| secondary\_tgw\_peering\_routing | ../../common/modules/network/tgw_routing | n/a |
| tgw\_peering\_primary\_to\_secondary | ../../common/modules/network/tgw_peering | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_vpc_ipam_organization_admin_account.ipam](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_vpc_ipam_organization_admin_account) | resource |
| [aws_ssm_parameter.account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_region.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.ct_log_archive_account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_availability\_zones | "Map of availability zones allowed to be used in this region." Example: ```aws_availability_zones = { primary_region = { az1 = "us-east-1a" az2 = "us-east-1b" } }``` | `map(any)` | n/a | yes |
| aws\_ip\_address\_plan | "Object with IP address plan which defines the CIDR blocks to be used in AWS regions." Example: ```aws_ip_address_plan = { global_cidr_blocks = ["10.10.0.0/16","10.20.0.0/16"] primary_region = { cidr_blocks = ["10.10.0.0/16"] shared = { cidr_blocks = ["10.10.0.0/18"] } prod = { cidr_blocks = ["10.10.64.0/18"] } stage = { cidr_blocks = ["10.10.128.0/18"] } dev = { cidr_blocks = ["10.10.192.0/18"] } } }``` | ```object({ global_cidr_blocks = list(string) primary_region = object({ cidr_blocks = list(string) shared = object({ cidr_blocks = list(string) }) prod = object({ cidr_blocks = list(string) }) stage = object({ cidr_blocks = list(string) }) dev = object({ cidr_blocks = list(string) }) }) })``` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->