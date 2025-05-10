# Log Archive Customization - Multi Region Advanced

This Terraform code is designed to set up additional AWS resources in the Control Tower's Log Archive account, extending the centralized logging hub to more services.

The following resources will be deployed by this solution (not limited to those below):

- AWS S3 Bucket for VPC Flow Logs

For more information, see the [Centralized Logs](https://awslabs.github.io/aft-blueprints/architectures/centralized-logs) architecture page.

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

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| aws.aft-management | n/a |
| aws.primary | n/a |
| aws.secondary | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aft\_custom\_fields | ../../common/modules/custom_fields | n/a |
| primary\_vpc\_flow\_logs | ../../common/modules/storage/s3_bucket_for_logs | n/a |
| secondary\_vpc\_flow\_logs | ../../common/modules/storage/s3_bucket_for_logs | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.primary_vpc_flow_logs_s3_bucket_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.secondary_vpc_flow_logs_s3_bucket_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->