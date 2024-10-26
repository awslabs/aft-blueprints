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
| [aws_cloudwatch_log_group.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudwatch\_log\_group | CloudWatch Log group configuration. Example: ```cloudwatch_log_group = { name = my-log-group retention_in_days = 30 kms_key_id = null skip_destroy = false log_group_class = "STANDARD" }``` | `map(string)` | `{}` | no |
| destination\_type | The destination type to capture: cloud-watch-logs or s3. This module doesn't support kinesis-data-firehose. | `string` | `"cloud-watch-logs"` | no |
| log\_format | The fields to include in the flow log record. Accepted format example: '${interface-id} ${srcaddr} ${srcport} ${dstaddr} ${dstport} ${protocol}' | `string` | `null` | no |
| max\_aggregation\_interval | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Expressed in seconds (e.g 60 = 1 minute) | `number` | `60` | no |
| resource\_id | The AWS resource ID to capture flow logs traffic. | `string` | n/a | yes |
| resource\_name | The AWS resource name to capture flow logs traffic. | `string` | n/a | yes |
| resource\_type | The AWS resource type to capture flow logs traffic. | `string` | n/a | yes |
| s3\_bucket\_arn | The ARN of the S3 bucket to export flow logs to. | `string` | `null` | no |
| s3\_destination\_options | The options for the flow log destination: file\_format, hive\_compatible\_partitions and per\_hour\_partition. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log#destination_options | ```object({ file_format = string # plain-text or parquet hive_compatible_partitions = bool   # true or false per_hour_partition = bool   # true or false })``` | ```{ "file_format": "parquet", "hive_compatible_partitions": true, "per_hour_partition": true }``` | no |
| tags | Tags to apply to resources. | `map(string)` | `{}` | no |
| traffic\_type | The traffic type to capture: ACCEPT, REJECT or ALL. | `string` | `"ALL"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->