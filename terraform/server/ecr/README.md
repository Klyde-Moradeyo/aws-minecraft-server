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
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_encryption_type"></a> [encryption\_type](#input\_encryption\_type) | Encryption type to use for the repository (AES256 or KMS) | `string` | `"AES256"` | no |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | Image tag mutability settings (MUTABLE or IMMUTABLE) | `string` | `"IMMUTABLE"` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the KMS key to use for encryption. Required if encryption\_type is KMS | `string` | `""` | no |
| <a name="input_lifecycle_policy_rules"></a> [lifecycle\_policy\_rules](#input\_lifecycle\_policy\_rules) | A list of maps defining lifecycle policy rules | <pre>list(object({<br>    rulePriority   = number<br>    description    = string<br>    selection_tag  = map(string)<br>    action_type    = string<br>    maximum_age    = number<br>    maximum_number = number<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the resources | `string` | n/a | yes |
| <a name="input_scan_on_push"></a> [scan\_on\_push](#input\_scan\_on\_push) | Indicates whether images are scanned after being pushed to the repository (true or false) | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags from tags module | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_encryption_type"></a> [encryption\_type](#output\_encryption\_type) | The encryption type of the ECR repository. |
| <a name="output_kms_key"></a> [kms\_key](#output\_kms\_key) | The KMS key ID used for encrypting the ECR repository. |
| <a name="output_lifecycle_policy"></a> [lifecycle\_policy](#output\_lifecycle\_policy) | The lifecycle policy applied to the ECR repository. |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | The Amazon Resource Name (ARN) of the created ECR repository. |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | n/a |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | ####################### ECR          # ####################### |
<!-- END_TF_DOCS -->