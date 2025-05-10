# Identity Management Customization - Multi Region Advanced

This Terraform code is designed to set up an identity management pipeline for AWS IAM Identity Center, providing an automated and dynamic way to manage Permission Sets in a multi-account environment. IAM Access Analyzer is also set up to perform external access analysis at the organization level.

The following resources will be deployed by this solution (not limited to those below):

- AWS CodePipeline
- AWS CodBuild
- Amazon EventBridge Rule
- AWS S3 Bucket
- AWS DynamoDB Table
- AWS IAM Access Analyzer

For more information, see the [Identity Management](https://awslabs.github.io/aft-blueprints/architectures/identity-management) architecture page.

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

### AWS Permission Set Pipeline

- **vcs_provider:** Inform if you want to use an external VCS provider, such as GitHub, or try to use AWS CodeCommit repository created by the solution. As AWS CodeCommit is no longer available to new customers, make sure your account is allowed to use the service. See more information in [What is AWS CodeCommit?](https://docs.aws.amazon.com/codecommit/latest/userguide/welcome.html)."
- **repository_name:** Provide a name for the AWS Permission Set pipeline repository. Inform the full repository path for external VCS, such as GitHub (e.g. GitHubOrganization/repository-name)."
- **branch_name:** Enter the name of the main branch for the repository.

After you have launched the account and deployed the pipeline, you must copy the contents of the [`assets/source/aws-ps-pipeline`](https://github.com/awslabs/aft-blueprints/tree/main/assets/source/aws-ps-pipeline) directory to the repository associated with the pipeline (AWS CodeCommit or GitHub). There you will find the Terraform files used to run the public module ["aws-ia/permission-sets/aws"](https://registry.terraform.io/modules/aws-ia/permission-sets/aws/latest) and apply a sample permission set defined in the `templates` directory. The Terraform backend configuration is dynamically provided in the pipeline by using **jinja2**, see the `providers.jinja` file.

If you have chosen to use an external VCS, such as Github, the solution will create an [AWS CodeStar Connections](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections.html) resource, for example `aws-ps-pipeline-connection`. You will need to manually authorize the pending connection by following the [Update a pending connection](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-update.html) documentation.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=1.5 |

## Providers

| Name | Version |
|------|---------|
| aws | 5.78.0 |
| aws.aft-management | 5.78.0 |
| aws.org-management | 5.78.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aft\_custom\_fields | ../../common/modules/custom_fields | n/a |
| aws\_ps\_pipeline | ../../common/modules/iam/permission-set-pipeline | n/a |
| primary\_iam\_access\_analyzer | ../../common/modules/iam/access-analyzer | n/a |
| secondary\_iam\_access\_analyzer | ../../common/modules/iam/access-analyzer | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_organizations_delegated_administrator.iam_access_analyzer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_delegated_administrator) | resource |
| [aws_organizations_delegated_administrator.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_delegated_administrator) | resource |
| [aws_ssm_parameter.account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| branch\_name | Repository main branch name for AWS Permission Set pipeline. | `string` | `"main"` | no |
| repository\_name | Repository name for AWS Permission Set pipeline. For external VCS, inform the full repository path (e.g. GitHubOrganization/repository-name). | `string` | `"myorg/aws-ps-pipeline"` | no |
| vcs\_provider | Customer VCS Provider - valid inputs are codecommit, github, or githubenterprise | `string` | `"github"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->