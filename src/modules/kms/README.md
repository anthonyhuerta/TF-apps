# kms

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account\_id | `string` | n/a | yes |
| <a name="input_kms_key_configs"></a> [kms\_key\_configs](#input\_kms\_key\_configs) | KMS keys and their associated policies | `map(any)` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A lowercase word to prepend to names of created resources | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"us-west-2"` | no |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | Resource name to be managed by the key | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_keys"></a> [kms\_keys](#output\_kms\_keys) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
