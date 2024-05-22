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
| <a name="module_resource_name_prefix"></a> [resource\_name\_prefix](#module\_resource\_name\_prefix) | km-tf-registry.onrender.com/klyde-moradeyo__dev-generic-tf-modules/resource-name-prefix/aws | 0.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.resource_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_cloudwatch_log_subscription_filter.subscription_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The base name of the resources | `string` | n/a | yes |
| <a name="input_resource_policies"></a> [resource\_policies](#input\_resource\_policies) | A list of CloudWatch log resource policies | <pre>list(object({<br>    name     = string<br>    document = string<br>  }))</pre> | `[]` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Retention period in days | `number` | `90` | no |
| <a name="input_subscription_filters"></a> [subscription\_filters](#input\_subscription\_filters) | A list of CloudWatch subscription filters | <pre>list(object({<br>    name            = string<br>    pattern         = string<br>    destination_arn = string<br>    role_arn        = string<br>    distribution    = string<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags from labels module | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_resource_policies"></a> [resource\_policies](#output\_resource\_policies) | The names of the CloudWatch log resource policies. |
| <a name="output_subscription_filters"></a> [subscription\_filters](#output\_subscription\_filters) | The names of the CloudWatch Log subscription filters. |
<!-- END_TF_DOCS -->