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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.custodian_s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| abort\_incomplete\_multipart\_upload\_days | Number of days after which Amazon S3 aborts an incomplete multipart upload. | `number` | `1` | no |
| aws\_kms\_customer\_managed\_key | Inform the AWS KMS Customer managed key ID to use to encrypt the S3 Bucket. If not set, the S3 Bucket will be encrypted with the AWS managed key. | `string` | `""` | no |
| aws\_organization\_service\_principals | Inform the AWS Organization service principals to access the S3 Bucket. If not set, no organization level access will be applied. | `list(string)` | `[]` | no |
| bucket\_name | S3 Bucket Name | `string` | n/a | yes |
| expiration\_days | Define the days to expire S3 objects. | `number` | `360` | no |
| noncurrent\_version\_expiration\_days | Define the days to expire non-current S3 objects. | `number` | `7` | no |
| noncurrent\_version\_transition\_rules | List of transition rules for non-current object versions for S3 bucket lifecycle configuration. | ```list(object({ noncurrent_days = number storage_class = string }))``` | ```[ { "noncurrent_days": 0, "storage_class": "INTELLIGENT_TIERING" } ]``` | no |
| tags | Tags to apply to the S3 Bucket | `map(any)` | `{}` | no |
| transition\_rules | List of transition rules for the S3 bucket lifecycle configuration. | ```list(object({ days = number storage_class = string }))``` | ```[ { "days": 0, "storage_class": "INTELLIGENT_TIERING" } ]``` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3\_bucket\_arn | S3 Bucket ARN |
| s3\_bucket\_name | S3 Bucket Name |
<!-- END_TF_DOCS -->