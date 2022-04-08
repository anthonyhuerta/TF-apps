# elasticsearch

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.44 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.44 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_elasticsearch_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain) | resource |
| [aws_elasticsearch_domain_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | AWS account ids to be attached to the elasticsearch domain policy | `list(any)` | n/a | yes |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to add to the IAM policies | `map(string)` | `{}` | no |
| <a name="input_clusters"></a> [clusters](#input\_clusters) | Multiple Elasticsearch clusters to the microservice's EKS service account role | `list(any)` | n/a | yes |
| <a name="input_elasticsearch_conf"></a> [elasticsearch\_conf](#input\_elasticsearch\_conf) | Map generated of elasticsearch configurations | `any` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A lowercase word to prepend to names of created resources | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The security group ids for the elasticsearch cluster | `list(any)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet ids for the elasticsearch clusters | `list(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_microservice_elasticsearch"></a> [microservice\_elasticsearch](#output\_microservice\_elasticsearch) | Elasticsearch clusters owned by microservices |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
