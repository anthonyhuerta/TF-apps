# Apps

Creates resources used by apps, the the majority of which are created using the `microservice` module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.44 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.73.0 |
| <a name="provider_aws.useast1"></a> [aws.useast1](#provider\_aws.useast1) | 3.73.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_secrets"></a> [app\_secrets](#module\_app\_secrets) | ./modules/secrets | n/a |
| <a name="module_cmk"></a> [cmk](#module\_cmk) | ./modules/kms | n/a |
| <a name="module_glue_secret"></a> [glue\_secret](#module\_glue\_secret) | ./modules/secrets | n/a |
| <a name="module_microservice_citus"></a> [microservice\_citus](#module\_microservice\_citus) | terraform-aws-modules/ec2-instance/aws | ~> 2.0 |
| <a name="module_microservice_eks_service_account_extra_policies"></a> [microservice\_eks\_service\_account\_extra\_policies](#module\_microservice\_eks\_service\_account\_extra\_policies) | ./modules/microservice-extra-policies | n/a |
| <a name="module_microservice_elasticsearch"></a> [microservice\_elasticsearch](#module\_microservice\_elasticsearch) | ./modules/elasticsearch | n/a |
| <a name="module_microservice_secrets"></a> [microservice\_secrets](#module\_microservice\_secrets) | ./modules/secrets | n/a |
| <a name="module_service_accounts_roles"></a> [service\_accounts\_roles](#module\_service\_accounts\_roles) | ./modules/service-account-roles | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.common](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudwatch_log_group.cloudfront_lambda_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_instance.microservice_postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_instance.microservice_postgres_replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.microservice_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_elasticache_parameter_group.microservice_redis_sidekiq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_parameter_group) | resource |
| [aws_elasticache_replication_group.microservice_redis_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_replication_group.microservice_redis_sidekiq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_glue_catalog_database.glue_catalog_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_connection.glue_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_connection) | resource |
| [aws_glue_crawler.glue_crawler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler) | resource |
| [aws_glue_job.glue_job](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job) | resource |
| [aws_glue_trigger.glue_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_trigger) | resource |
| [aws_iam_policy.microservice_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cloudfront_lambda_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.glue_datalake](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.kinesis_firehose_apigee_api_stats](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.microservice_eks_service_accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.athena_query_execution_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.cloudfront_lambda_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.datalake_read_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.kinesis_firehose_apigee_access_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.kinesis_firehose_apigee_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.glue_awsmanaged_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.microservice_eks_service_accounts_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_key_pair.citus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_kinesis_firehose_delivery_stream.apigee_api_stats](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_lambda_function.cloudfront_lambda_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_mq_broker.amq_broker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_broker) | resource |
| [aws_mq_configuration.amq_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_configuration) | resource |
| [aws_route53_record.cloudfront_distributions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.microservice_postgres_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.helm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_secretsmanager_secret.amq_random_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.microservice_postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.microservice_redis_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.microservice_redis_sidekiq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.amq_random_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.microservice_postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.microservice_redis_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.microservice_redis_sidekiq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group_rule.rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sns_topic.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.microservice_medium](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.microservice_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.microservice_medium](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.microservice_medium](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [random_password.amq_random_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.microservice_postgres](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.microservice_redis_cache](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.microservice_redis_sidekiq](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.citus](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [archive_file.lambda_source](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.glue_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kinesis_firehose_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_edge_function_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.cloudfront_distributions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_secretsmanager_secret_version.glue_db_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.microservice_postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [terraform_remote_state.master_org](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_config_dir"></a> [app\_config\_dir](#input\_app\_config\_dir) | Directory containing app config yaml relative to asm.tf | `string` | `"config/microservices/"` | no |
| <a name="input_cloudfront_config_dir"></a> [cloudfront\_config\_dir](#input\_cloudfront\_config\_dir) | Directory relative to `cloudfront_distributions.tf` containing config yaml for cloudfront distributions | `string` | `"config/cloudfront/"` | no |
| <a name="input_env"></a> [env](#input\_env) | Name of the environment, eg prod | `string` | n/a | yes |
| <a name="input_kms_config_dir"></a> [kms\_config\_dir](#input\_kms\_config\_dir) | Directory containing kms config yaml | `string` | `"config/kms/"` | no |
| <a name="input_legacy_datalake_bucket_arn"></a> [legacy\_datalake\_bucket\_arn](#input\_legacy\_datalake\_bucket\_arn) | The arn of womply\_datalake\_data bucket exit in the legacy account | `string` | `"arn:aws:s3:::womply-datalake-data"` | no |
| <a name="input_microservice_config_dir"></a> [microservice\_config\_dir](#input\_microservice\_config\_dir) | Directory containing microservice config yaml relative to microservices.tf | `string` | `"config/microservices/"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A lowercase word to prepend to names of created resources | `string` | `""` | no |
| <a name="input_private_infrastructure"></a> [private\_infrastructure](#input\_private\_infrastructure) | Whether all created infrastructure should only be available when using VPN | `bool` | `true` | no |
| <a name="input_realm"></a> [realm](#input\_realm) | Maps to our organization on TFC: womply, cde | `string` | `"womply"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"us-west-2"` | no |
| <a name="input_sgrules_config_dir"></a> [sgrules\_config\_dir](#input\_sgrules\_config\_dir) | Directory containing security group rules config yaml relative to main.tf | `string` | `"config/sgrules/"` | no |
| <a name="input_tfc_workspaces"></a> [tfc\_workspaces](#input\_tfc\_workspaces) | The Terraform Cloud workspaces that this one has as dependencies | `map(string)` | <pre>{<br>  "clusters": "",<br>  "network": ""<br>}</pre> | no |
| <a name="input_topic_config_dir"></a> [topic\_config\_dir](#input\_topic\_config\_dir) | Directory containing topic config yaml relative to topics.tf | `string` | `"config/topics/"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_secrets"></a> [app\_secrets](#output\_app\_secrets) | The ARN and name of secrets added to AWS Secrets Manager for each apps |
| <a name="output_citus_key_pair_fingerprint"></a> [citus\_key\_pair\_fingerprint](#output\_citus\_key\_pair\_fingerprint) | AWS Key Pair Fingerprint used for citus instances |
| <a name="output_citus_key_pair_name"></a> [citus\_key\_pair\_name](#output\_citus\_key\_pair\_name) | AWS Key Pair Name used for citus instances |
| <a name="output_citus_key_private_pem"></a> [citus\_key\_private\_pem](#output\_citus\_key\_private\_pem) | Private SSH key for citus instances in PEM format |
| <a name="output_citus_key_public_openssh"></a> [citus\_key\_public\_openssh](#output\_citus\_key\_public\_openssh) | Public SSH key for citus instances in OpenSSH authorized\_keys format |
| <a name="output_cloudfront_distributions"></a> [cloudfront\_distributions](#output\_cloudfront\_distributions) | Cloudfront distributions created by this root module |
| <a name="output_glue_jobs"></a> [glue\_jobs](#output\_glue\_jobs) | Glue jobs created for microservices |
| <a name="output_kms_keys"></a> [kms\_keys](#output\_kms\_keys) | n/a |
| <a name="output_microservice_alerts"></a> [microservice\_alerts](#output\_microservice\_alerts) | Information on microservice ownership and alerting information |
| <a name="output_microservice_citus"></a> [microservice\_citus](#output\_microservice\_citus) | EC2 instances owned by citus |
| <a name="output_microservice_eks_service_account_roles"></a> [microservice\_eks\_service\_account\_roles](#output\_microservice\_eks\_service\_account\_roles) | IAM roles used by Microservices' Kubernetes ServiceAccounts |
| <a name="output_microservice_elasticsearch"></a> [microservice\_elasticsearch](#output\_microservice\_elasticsearch) | The ARN and name of secrets added to AWS Secrets Manager for each microservice |
| <a name="output_microservice_postgres"></a> [microservice\_postgres](#output\_microservice\_postgres) | Postgres database owned by microservices |
| <a name="output_microservice_postgres_replica"></a> [microservice\_postgres\_replica](#output\_microservice\_postgres\_replica) | Postgres database owned by microservices |
| <a name="output_microservice_queues"></a> [microservice\_queues](#output\_microservice\_queues) | Queues owned by microservices |
| <a name="output_microservice_redis_cache"></a> [microservice\_redis\_cache](#output\_microservice\_redis\_cache) | Redis clusters used for caching by microservices |
| <a name="output_microservice_redis_sidekiq"></a> [microservice\_redis\_sidekiq](#output\_microservice\_redis\_sidekiq) | Redis clusters used for Sidekiq queues by microservices |
| <a name="output_microservice_secrets"></a> [microservice\_secrets](#output\_microservice\_secrets) | The ARN and name of secrets added to AWS Secrets Manager for each microservice |
| <a name="output_monitor_kubernetes_apps"></a> [monitor\_kubernetes\_apps](#output\_monitor\_kubernetes\_apps) | A map of apps running on Kubernetes and the associated parameters used for monitoring |
| <a name="output_topics"></a> [topics](#output\_topics) | All SNS topics managed via this root module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
