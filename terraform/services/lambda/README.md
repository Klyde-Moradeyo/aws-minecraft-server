<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_log"></a> [cloudwatch\_log](#module\_cloudwatch\_log) | km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/cloudwatch-log-group/aws | 0.0.1 |
| <a name="module_iam_policy"></a> [iam\_policy](#module\_iam\_policy) | km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-policy/aws | 0.0.1 |
| <a name="module_iam_role"></a> [iam\_role](#module\_iam\_role) | km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/iam-role/aws | 0.0.1 |
| <a name="module_resource_name_prefix"></a> [resource\_name\_prefix](#module\_resource\_name\_prefix) | km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws | 0.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_lambda_function.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | The description of the Lambda function. | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment variables for the Lambda function. | `map(string)` | `{}` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | The entry point in your code. | `string` | `""` | no |
| <a name="input_iam_policy_statements"></a> [iam\_policy\_statements](#input\_iam\_policy\_statements) | The list of policy statements for the Lambda execution role. | `list(any)` | <pre>[<br>  {<br>    "Action": [<br>      "logs:CreateLogGroup",<br>      "logs:CreateLogStream",<br>      "logs:PutLogEvents"<br>    ],<br>    "Effect": "Allow",<br>    "Resource": "*"<br>  }<br>]</pre> | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | URI of a Docker image containing the Lambda function. | `string` | `""` | no |
| <a name="input_layers"></a> [layers](#input\_layers) | A list of Lambda layer ARNs. | `list(string)` | `[]` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | The amount of memory in MB your Lambda function can use at runtime. | `number` | `128` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the resources | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | A list of Lambda permissions. | <pre>list(object({<br>    action     = string<br>    principal  = string<br>    source_arn = string<br>  }))</pre> | `[]` | no |
| <a name="input_publish"></a> [publish](#input\_publish) | Whether to publish creation/change as a new Lambda function version. | `bool` | `false` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | The maximum number of concurrent executions reserved for this function. | `number` | `-1` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The runtime environment for the Lambda function. | `string` | `""` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | The name of the S3 bucket containing the Lambda function code. | `string` | `""` | no |
| <a name="input_s3_file_hash"></a> [s3\_file\_hash](#input\_s3\_file\_hash) | Base64-encoded SHA256 hash of the S3 file. | `string` | `""` | no |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | The S3 key of the Lambda function code. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign | `map(string)` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The timeout for the Lambda function. | `number` | `30` | no |
| <a name="input_zip_file"></a> [zip\_file](#input\_zip\_file) | Path to the local ZIP file containing the Lambda function code. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the Lambda function. |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The IAM role for the Lambda function. |
| <a name="output_image_uri"></a> [image\_uri](#output\_image\_uri) | The image URI of the Lambda function. |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | The Invoke ARN of the Lambda function. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Lambda function. |
| <a name="output_zip_file"></a> [zip\_file](#output\_zip\_file) | The local ZIP file path of the Lambda function. |
<!-- END_TF_DOCS -->