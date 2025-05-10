# Global Customizations

Before start using the repository, you must define the regions you want to use in the `aft-config.j2` file:

```json
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

See below the list of available global configurations:

## IAM Password Policy

According to AWS Security Best Practices, it is strongly recommended to implement a robust password policy for all IAM users. We therefore consider this configuration a mandatory requirement across all accounts. No configuration is needed.

## Account Default Configuration

AWS Offers a few configuration options to be applied at account level, such as S3 Block Public Access, AMI Block Public Access, EBS Encryption Enforcement and IMDSv2 Enforcement. We make these settings available via a module, and you can set the value of whether each of these items should be applied by default or not.

Find the module `default_account_config_*` in the `main.tf` file and change the **lookup** default value for each configuration option: `lookup(local.features, "feature_name", true|false)`.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aft\_custom\_fields | ./modules/custom_fields | n/a |
| default\_account\_config\_primary | ./modules/default_account_config | n/a |
| default\_account\_config\_secondary | ./modules/default_account_config | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_account_password_policy.strict](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->