# APP_DEV Customization

This Terraform configuration is a sample that shows how to customize an workload account in a single AWS region environment.

The following resources will be deployed by this solution (not limited to those below):

- AWS Virtual Private Cloud (VPC)
- AWS Transit Gateway VPC attachment
- Amazon EC2 instance for tests (bastion host)
- Amazon Route53 Private Hosted Zone

For more information, see the [Workload account](https://awslabs.github.io/aft-blueprints/architectures/workload-account/) architecture page.

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

Use the AFT `custom_fields` field in the account request file to provide values for the blueprint:

```terraform
custom_fields = {

  # Use it to provide the Private Hosted Zone name
  phz_name = "myapp.dev.on.aws"

  # Use it to provide the VPC parameters
  vpc = jsonencode({
    environment = "dev"
    vpc_size    = "small"
  })

  # Use it to provide tag values for all resources
  tags = jsonencode({
    env = "dev"
  })

  # Use it to provide a feature flag mechanism for creating resources at the global customization level
  features = jsonencode({
    ebs_encryption = false
    imdsv2         = false
  })
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws.aft-management | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aft\_custom\_fields | ../../common/modules/custom_fields | n/a |
| primary\_region | ./blueprint | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.network_account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->