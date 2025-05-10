<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~>1.6 |

## Providers

| Name | Version |
|------|---------|
| aws.aft-management | 5.78.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aft\_custom\_fields | ../../common/modules/custom_fields | n/a |
| primary\_region | ./blueprint | n/a |
| secondary\_region | ./blueprint | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.backup_account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.network_account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->