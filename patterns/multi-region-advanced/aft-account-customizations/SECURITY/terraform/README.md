# Security Tooling Customization - Multi Region Advanced

This Terraform code is designed to set up additional AWS resources in the Control Tower's Log Archive account, extending the centralized logging hub to more services.

The following resources will be deployed by this solution (not limited to those below):

- Amazon GuardDuty
- AWS Security Hub

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

Update the `variable.auto.tfvars` file with the corresponding values for:

### Amazon GuardDuty

- **guardduty_auto_enable_organization_members:** Inform if you want to automatically enable the service for all accounts in the organization.

### AWS Security Hub

- **securityhub_control_finding_generator:** Inform if you want to turn on consolidated control findings (SECURITY_CONTROL).
- **securityhub_enabled_standard_arns:** Inform the list of security standards ARNs that you want to enable. Be sure to use your primary region when entering the ARN.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| aws.aft-management | n/a |
| aws.org-management-primary | n/a |
| aws.org-management-secondary | n/a |
| aws.primary | n/a |
| aws.secondary | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aft\_custom\_fields | ../../common/modules/custom_fields | n/a |
| primary\_guardduty | ../../common/modules/security/guardduty | n/a |
| secondary\_guardduty | ../../common/modules/security/guardduty | n/a |
| securityhub | ../../common/modules/security/securityhub | n/a |
| securityhub\_default\_policy | ../../common/modules/security/securityhub_policy | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_organization_admin_account.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource |
| [aws_guardduty_organization_admin_account.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource |
| [aws_securityhub_account.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_organization_admin_account.securityhub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_admin_account) | resource |
| [aws_ssm_parameter.account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_organizations_organization.root_ou](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_region.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| guardduty\_auto\_enable\_organization\_members | Define whether enable GuardDuty Organization Configuration or not. | `string` | `"ALL"` | no |
| securityhub\_control\_finding\_generator | Define whether the Security Hub calling account has consolidated control findings turned on. | `string` | `"SECURITY_CONTROL"` | no |
| securityhub\_enabled\_standard\_arns | List of AWS Security Hub standard ARNs to enable. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->