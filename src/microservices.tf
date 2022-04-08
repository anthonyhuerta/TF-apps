#####
# Local Vars
#####

locals {
  microservice_file_paths = fileset(path.module, "${var.microservice_config_dir}/**/*-service.yaml")
  microservice_configs = {
    for x in flatten([
      for file_path in local.microservice_file_paths : [
        for microservice, obj in yamldecode(file(file_path)) : {
          (microservice) = obj
        }
      ]
    ]) : keys(x)[0] => values(x)[0]
  }

  microservice_config_has = { for k, v in local.microservice_configs : k => {
    amq              = lookup(v, "amq", { create = false }) != { create = false }
    citus            = lookup(v, "citus", { create = false }) != { create = false }
    elasticsearch    = lookup(v, "elasticsearch", { create = false }) != { create = false }
    glue             = lookup(v, "glue", { create = false }) != { create = false }
    kubernetes       = lookup(v, "kubernetes", { create = false }) != { create = false }
    postgres         = lookup(v, "postgres", { create = false }) != { create = false }
    postgres_replica = lookup(v, "postgres-replica", { create = false }) != { create = false }
    queues           = lookup(v, "queues", { create = false }) != { create = false }
    redis_cache      = lookup(v, "redis-cache", { create = false }) != { create = false }
    redis_sidekiq    = lookup(v, "redis-sidekiq", { create = false }) != { create = false }
    topics           = lookup(v, "topics", { create = false }) != { create = false }
  } }

  microservice_amq = { for k, v in local.microservice_configs : k => merge(
    {
      name = k
    },
    v.amq,
  ) if local.microservice_config_has[k].amq }

  microservice_citus = { for k, v in local.microservice_configs : k => merge(
    {
      name = k
    },
    v.citus,
  ) if local.microservice_config_has[k].citus }

  microservice_elasticsearch = { for k, v in local.microservice_configs : k => merge(
    {
      name = k
    },
    v.elasticsearch,
  ) if local.microservice_config_has[k].elasticsearch }

  microservice_glue = { for k, v in local.microservice_configs : k => merge(
    {
      name = k
    },
    v.glue,
  ) if local.microservice_config_has[k].glue }

  microservice_glue_jobs = flatten([for k, v in local.microservice_glue : [
    for name, job_properties in v.jobs : {
      microservice_name = k
      name              = name
      properties        = job_properties
  }]])

  microservice_glue_connections = flatten([for k, v in local.microservice_glue : [
    for name, connection_properties in v.connections : {
      microservice_name     = k
      name                  = name
      connection_properties = connection_properties
  }]])

  microservice_glue_crawlers = flatten([for k, v in local.microservice_glue : [
    for name, crawler_properties in v.crawlers : {
      microservice_name = k
      name              = name
      crawl_properties  = crawler_properties
  }]])

  microservice_glue_triggers = flatten([for k, v in local.microservice_glue : [
    for name, trigger_properties in v.triggers : {
      microservice_name  = k
      name               = name
      trigger_properties = trigger_properties
  }]])

  microservice_kubernetes = { for k, v in local.microservice_configs : k => merge(
    {
      name              = k
      namespace         = "apps"
      cluster           = "main"
      team              = v.team
      pagerduty_enabled = lookup(v, "pagerduty_enabled", false)
      slack_channel     = lookup(v, "slack_channel", "")
    },
    lookup(v, "kubernetes", {})
  ) }

  microservice_postgres = { for k, v in local.microservice_configs : k => merge(
    {
      name = k
    },
    v.postgres,
  ) if local.microservice_config_has[k].postgres }

  microservice_postgres_replica = { for k, v in local.microservice_configs : k => merge(
    {
      name = k
    },
    v.postgres,
  ) if local.microservice_config_has[k].postgres_replica }

  microservice_queues = { for k, v in local.microservice_configs : k => {
    dlq    = local.microservice_config_has[k].queues ? lookup(local.microservice_configs[k].queues, "dlq", {}) : {}
    low    = local.microservice_config_has[k].queues ? lookup(local.microservice_configs[k].queues, "low", {}) : {}
    medium = local.microservice_config_has[k].queues ? lookup(local.microservice_configs[k].queues, "medium", {}) : {}
    high   = local.microservice_config_has[k].queues ? lookup(local.microservice_configs[k].queues, "high", {}) : {}
  } }

  microservice_redis_cache = { for k, v in local.microservice_configs : k => merge(
    {
      name = k
    },
    v.redis-cache,
  ) if local.microservice_config_has[k].redis_cache }

  microservice_redis_sidekiq = { for k, v in local.microservice_configs : k => merge(
    {
      name = k
    },
    v.redis-sidekiq,
  ) if local.microservice_config_has[k].redis_sidekiq }

  microservice_topics = { for k, v in local.microservice_configs : k => {
    arns  = try(local.microservice_configs[k].topics.arns, [])
    names = try(local.microservice_configs[k].topics.names, [])
  } }

  microservice_topic_arns_pairs = flatten([
    for microservice, topics in local.microservice_topics : [
      for topic_arn in topics.arns : {
        microservice = microservice
        topic_arn    = topic_arn
      }
    ]
  ])
  # When given only a topic name it assumes the same account and region
  microservice_topic_names_pairs = flatten([
    for microservice, topics in local.microservice_topics : [
      for topic_name in topics.names : {
        microservice = microservice
        # for_each keys must be known in advance of `terraform plan`
        topic_arn = "arn:aws:sns:${var.region}:${local.account_id}:${topic_name}"
      }
    ]
  ])
  microservice_topic_joins = {
    for obj in concat(local.microservice_topic_names_pairs, local.microservice_topic_arns_pairs) :
    "${obj.microservice}-service|${obj.topic_arn}" => obj
  }

  # This variable is to override the default value for each parameter-group
  # increasing the value of this parameter will allow postgres to store
  # long queries size upto 30000 bytes.
  postgres_default_override_parameters = [{
    name         = "track_activity_query_size"
    value        = "30000"
    apply_method = "pending-reboot"
  }]
}

#####
# IAM Roles
#####

resource "aws_iam_role" "microservice_eks_service_accounts" {
  for_each = local.microservice_kubernetes

  name        = "${local.prefix_dash}eks-${each.value["cluster"]}-${each.value["namespace"]}-${each.key}-service"
  path        = lookup(each.value, "path", null)
  description = "Role for Kubernetes ServiceAccount sa/${each.key}-service in namespace ${each.value["namespace"]}"

  assume_role_policy = templatefile("${path.root}/config/policies/trust-relationships/assume-eks-service-accounts-role.json.tmpl", {
    oidc_provider_arn = local.cluster_oidc_provider_arn
    oidc_provider_url = local.cluster_oidc_provider_url
    namespace         = each.value["namespace"]
    # Transition step: Support keys & service accounts both with and without suffix "-service"
    # Can be changed to simply [each.key] after key name switch
    service_account_names = concat(["${each.key}-service"], lookup(local.microservice_configs[each.key], "extra-service-accounts", []))
  })

  tags = merge(local.common_tags, {
    "Name"                 = "${local.prefix_dash}eks-${each.value["cluster"]}-${each.value["namespace"]}-${each.key}-service"
    "Cluster"              = each.value["cluster"]
    "Kubernetes:Kind"      = "ServiceAccount"
    "Kubernetes:Namespace" = each.value["namespace"]
    "Microservice"         = each.key
  })
}

#####
# SQS
#####

resource "aws_sqs_queue" "microservice_dlq" {
  for_each = local.microservice_configs

  name = "${local.prefix_dash}${each.key}-service-dlq"

  message_retention_seconds = tonumber(lookup(local.microservice_queues[each.key].dlq, "message_retention_seconds", 1209600)) # 14 days - the maximum allowed

  tags = merge(local.common_tags, {
    "Name"         = "${local.prefix_dash}${each.key}-service-dlq"
    "Microservice" = each.key
  })
}

resource "aws_sqs_queue" "microservice_medium" {
  for_each = local.microservice_configs

  name = "${local.prefix_dash}${each.key}-service-medium"

  message_retention_seconds  = tonumber(lookup(local.microservice_queues[each.key].medium, "message_retention_seconds", 86400)) # 1 day
  delay_seconds              = tonumber(lookup(local.microservice_queues[each.key].medium, "delay_seconds", null))              # Defaults to 0
  receive_wait_time_seconds  = tonumber(lookup(local.microservice_queues[each.key].medium, "receive_wait_time_seconds", null))  # Defaults to 0
  visibility_timeout_seconds = tonumber(lookup(local.microservice_queues[each.key].medium, "visibility_timeout_seconds", null)) # Defaults to 30

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.microservice_dlq[each.key].arn
    maxReceiveCount     = tonumber(lookup(local.microservice_queues[each.key].medium, "redrive_max_receive_count", 5))
  })

  tags = merge(local.common_tags, {
    "Name"         = "${local.prefix_dash}${each.key}-service-medium"
    "Microservice" = each.key
  })
}

resource "aws_sqs_queue_policy" "microservice_medium" {
  for_each = local.microservice_configs

  queue_url = aws_sqs_queue.microservice_medium[each.key].id
  policy = templatefile("${path.module}/config/policies/service-access/microservice_queue.json.tmpl", {
    resource_arn = aws_sqs_queue.microservice_medium[each.key].arn
    topic_arns   = [for k, v in local.microservice_topic_joins : v.topic_arn if v.microservice == each.key]
  })
}

# Add filtering by priority messages after message schema is complete
resource "aws_sns_topic_subscription" "microservice_medium" {
  for_each = local.microservice_topic_joins

  topic_arn            = each.value.topic_arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.microservice_medium[each.value.microservice].arn
  raw_message_delivery = true
  filter_policy        = lookup(local.microservice_configs[each.value.microservice].topics, "filters", null)
  depends_on           = [aws_sns_topic.all]
}

resource "aws_iam_policy" "microservice_core" {
  for_each = local.microservice_configs

  name        = "${local.prefix_dash}${each.key}-service"
  description = "Core Policy for Microservice ${each.key}"
  policy = templatefile("${path.module}/config/policies/iam-permissions/microservice_core.json.tmpl", {
    env                = var.env
    elasticsearch_arns = ["arn:aws:es:${var.region}:${local.account_id}:domain/${local.prefix_dash}${each.key}*"]
    microservice_alias = each.value.alias
    microservice_name  = "${each.key}-service"
    queue_arns = [
      aws_sqs_queue.microservice_dlq[each.key].arn,
      # aws_sqs_queue.microservice_low[each.key].arn,
      aws_sqs_queue.microservice_medium[each.key].arn,
      # aws_sqs_queue.microservice_high[each.key].arn,
    ]
    topic_arns = ["arn:aws:sns:us-west-2:${local.account_id}:${local.prefix_dash}soa-*"]
  })
}


resource "aws_iam_role_policy_attachment" "microservice_eks_service_accounts_core" {
  for_each = local.microservice_kubernetes

  role       = aws_iam_role.microservice_eks_service_accounts[each.key].name
  policy_arn = aws_iam_policy.microservice_core[each.key].arn
}

#####
# Elasticsearch
#####

module "microservice_elasticsearch" {
  for_each = local.microservice_elasticsearch

  source             = "./modules/elasticsearch"
  clusters           = lookup(each.value, "clusters", [])
  elasticsearch_conf = local.microservice_elasticsearch[each.key]
  subnet_ids = sort([
    local.subnets.database.ids[0],
    local.subnets.database.ids[1],
    local.subnets.database.ids[2],
  ])
  account_ids        = sort([local.account_id, local.account_ids["legacy"]])
  security_group_ids = [local.security_groups.elasticsearch.id]
  prefix             = var.prefix
  additional_tags = merge(local.common_tags, {
    "Microservice" = each.key
  })
}

#####
# Redis
#####

# Redis default parameter group used by a microservice
resource "random_password" "microservice_redis_cache" {
  for_each = local.microservice_redis_cache
  special  = false
  length   = 16
}

resource "aws_secretsmanager_secret" "microservice_redis_cache" {
  for_each = local.microservice_redis_cache

  name                    = "${local.slash_prefix}/apps/${each.key}/redis-cache-password"
  recovery_window_in_days = 0

  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.common_tags, {
    "Name"         = "${local.slash_prefix}/apps/${each.key}/redis-cache-password"
    "Microservice" = each.key
  })
}

resource "aws_secretsmanager_secret_version" "microservice_redis_cache" {
  for_each = local.microservice_redis_cache

  secret_id     = aws_secretsmanager_secret.microservice_redis_cache[each.key].id
  secret_string = random_password.microservice_redis_cache[each.key].result

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_elasticache_replication_group" "microservice_redis_cache" {
  for_each = local.microservice_redis_cache

  at_rest_encryption_enabled    = true
  auth_token                    = random_password.microservice_redis_cache[each.key].result
  automatic_failover_enabled    = true
  engine                        = "redis"
  engine_version                = local.microservice_redis_cache[each.key].version
  maintenance_window            = "sun:03:00-sun:04:00"
  node_type                     = local.microservice_redis_cache[each.key].instance_type
  number_cache_clusters         = tonumber(lookup(local.microservice_redis_cache[each.key], "instance_count", 2))
  replication_group_description = "Redis cluster for ${local.prefix_dash}${each.key}"
  replication_group_id          = "${local.prefix_dash}${each.key}"
  security_group_ids            = [local.security_groups.redis.id]
  snapshot_retention_limit      = 0
  subnet_group_name             = local.elasticache_subnet_group
  transit_encryption_enabled    = true

  tags = merge(local.common_tags, {
    "Name"         = "${local.prefix_dash}${each.key}"
    "Microservice" = each.key
  })
}

# Redis noeviction parameter group used by a microservice's sidekiq queue
resource "aws_elasticache_parameter_group" "microservice_redis_sidekiq" {
  for_each = local.microservice_redis_sidekiq

  name        = "${local.prefix_dash}${each.key}-sidekiq"
  description = "Redis with maxmemory-policy set to noeviction"

  family = local.microservice_redis_sidekiq[each.key].parameter_version

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "random_password" "microservice_redis_sidekiq" {
  for_each = local.microservice_redis_sidekiq
  special  = false
  length   = 16
}

resource "aws_secretsmanager_secret" "microservice_redis_sidekiq" {
  for_each = local.microservice_redis_sidekiq

  name                    = "${local.slash_prefix}/apps/${each.key}/redis-sidekiq-password"
  recovery_window_in_days = 0

  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.common_tags, {
    "Name"         = "${local.slash_prefix}/apps/${each.key}/redis-sidekiq-password"
    "Microservice" = each.key
  })
}

resource "aws_secretsmanager_secret_version" "microservice_redis_sidekiq" {
  for_each = local.microservice_redis_sidekiq

  secret_id     = aws_secretsmanager_secret.microservice_redis_sidekiq[each.key].id
  secret_string = random_password.microservice_redis_sidekiq[each.key].result

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_elasticache_replication_group" "microservice_redis_sidekiq" {
  for_each = local.microservice_redis_sidekiq

  at_rest_encryption_enabled    = true
  auth_token                    = random_password.microservice_redis_sidekiq[each.key].result
  engine                        = "redis"
  engine_version                = local.microservice_redis_sidekiq[each.key].version
  maintenance_window            = "sun:03:00-sun:04:00"
  node_type                     = local.microservice_redis_sidekiq[each.key].instance_type
  number_cache_clusters         = tonumber(lookup(local.microservice_redis_sidekiq[each.key], "instance_count", 2))
  parameter_group_name          = aws_elasticache_parameter_group.microservice_redis_sidekiq[each.key].name
  replication_group_description = "Redis sidekiq cluster for ${local.prefix_dash}${each.key}"
  replication_group_id          = "${local.prefix_dash}${each.key}-sidekiq"
  security_group_ids            = [local.security_groups.redis.id]
  snapshot_retention_limit      = 5
  subnet_group_name             = local.elasticache_subnet_group
  transit_encryption_enabled    = true

  tags = merge(local.common_tags, {
    "Name"         = "${local.prefix_dash}${each.key}-sidekiq"
    "Microservice" = each.key
  })
}

#####
# AWS Secrets Manager
#####

module "microservice_secrets" {
  for_each = { for k, v in local.microservice_configs : k => lookup(v, "secrets", {}) }

  source = "./modules/secrets"

  secret_prefix = "${local.slash_prefix}/apps/${each.key}-service/"
  secret_names  = { for k in each.value : k => "" }

  recovery_window_in_days = 0

  additional_tags = merge(local.common_tags, {
    "Microservice" = each.key
  })
}

#####
# Extra Policies
#####

module "microservice_eks_service_account_extra_policies" {
  for_each = local.microservice_configs

  source    = "./modules/microservice-extra-policies"
  policies  = lookup(each.value, "extra-policies", {})
  role_name = aws_iam_role.microservice_eks_service_accounts[each.key].name

  additional_tags = merge(local.common_tags, {
    "Microservice" = each.key
  })
}
#####
# AWS RDS
#####

resource "random_password" "microservice_postgres" {
  for_each = local.microservice_postgres
  special  = false
  length   = 32
}

resource "aws_secretsmanager_secret" "microservice_postgres" {
  for_each = local.microservice_postgres

  name                    = "${local.slash_prefix}/aws-resources/rds/${local.prefix_dash}${each.key}-service/root-password"
  recovery_window_in_days = 0

  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.common_tags, {
    "Name"         = "${local.slash_prefix}/aws-resources/rds/${local.prefix_dash}${each.key}-service/root-password"
    "Microservice" = "${each.key}-service"
  })
}

resource "aws_secretsmanager_secret_version" "microservice_postgres" {
  for_each = local.microservice_postgres

  secret_id     = aws_secretsmanager_secret.microservice_postgres[each.key].id
  secret_string = random_password.microservice_postgres[each.key].result

  lifecycle {
    ignore_changes = [secret_string]
  }
}

data "aws_secretsmanager_secret_version" "microservice_postgres" {
  for_each  = aws_secretsmanager_secret_version.microservice_postgres
  secret_id = aws_secretsmanager_secret.microservice_postgres[each.key].id
}

resource "aws_db_instance" "microservice_postgres" {
  for_each = local.microservice_postgres

  identifier = "${local.prefix_dash}${each.key}-service-postgres-${local.microservice_postgres[each.key].index}"

  allocated_storage                   = lookup(local.microservice_postgres[each.key], "storage", 100)             # GB
  apply_immediately                   = lookup(local.microservice_postgres[each.key], "apply_immediately", false) # Whether to apply before maintenance window
  auto_minor_version_upgrade          = lookup(local.microservice_postgres[each.key], "auto_minor_version_upgrade", true)
  backup_retention_period             = lookup(local.microservice_postgres[each.key], "backup_period", 3) # Days
  backup_window                       = "05:00-06:00"                                                     # UTC
  db_subnet_group_name                = local.database_subnet_group
  engine                              = "postgres"
  engine_version                      = local.microservice_postgres[each.key].version
  iam_database_authentication_enabled = true
  instance_class                      = local.microservice_postgres[each.key].instance_class
  iops                                = lookup(local.microservice_postgres[each.key], "iops", null)
  kms_key_id                          = lookup(local.microservice_postgres[each.key], "storage_encrypted", false) == true ? module.cmk.kms_keys[lookup(local.microservice_postgres[each.key], "kms_key", "rds-cmk")].arn : null
  maintenance_window                  = "Sun:04:00-Sun:04:30" # UTC
  multi_az                            = tobool(lookup(local.microservice_postgres[each.key], "multi_az", true))
  name                                = try(each.value.name)
  parameter_group_name                = aws_db_parameter_group.microservice_parameter_group[each.key].name
  performance_insights_enabled        = tobool(lookup(local.microservice_postgres[each.key], "performance_insights", false))
  performance_insights_kms_key_id     = lookup(local.microservice_postgres[each.key], "performance_insights", false) == true ? module.cmk.kms_keys[lookup(local.microservice_postgres[each.key], "kms_key", "rds-cmk")].arn : null
  port                                = 5432
  final_snapshot_identifier           = lookup(local.microservice_postgres[each.key], "final_snapshot_identifier", "${local.prefix_dash}${each.key}")
  storage_encrypted                   = lookup(local.microservice_postgres[each.key], "storage_encrypted", true)
  snapshot_identifier                 = lookup(local.microservice_postgres[each.key], "snapshot_identifier", null)
  vpc_security_group_ids              = [local.security_groups.postgres.id]

  username = lookup(local.microservice_postgres[each.key], "root_user", "") == "" ? "root" : lookup(local.microservice_postgres[each.key], "root_user")
  password = aws_secretsmanager_secret_version.microservice_postgres[each.key].secret_string
  ## Use the following instead after upgrading to Terraform version >= 0.14
  # password = data.aws_secretsmanager_secret_version.microservice_postgres[each.key].secret_string

  tags = merge(local.common_tags, {
    "Name"         = "${local.prefix_dash}${each.key}-service-postgres-${local.microservice_postgres[each.key].index}"
    "Microservice" = each.key
  })
}

resource "aws_db_instance" "microservice_postgres_replica" {
  for_each = local.microservice_postgres_replica

  identifier = "${aws_db_instance.microservice_postgres[each.key].identifier}-replica-${local.microservice_postgres_replica[each.key].index}"

  allocated_storage                   = lookup(local.microservice_postgres[each.key], "storage", 100)             # Same as primary
  apply_immediately                   = lookup(local.microservice_postgres[each.key], "apply_immediately", false) # Whether to apply before maintenance window
  auto_minor_version_upgrade          = lookup(local.microservice_postgres[each.key], "auto_minor_version_upgrade", true)
  engine                              = "postgres"
  engine_version                      = local.microservice_postgres[each.key].version # Same as primary
  iam_database_authentication_enabled = true
  instance_class                      = local.microservice_postgres_replica[each.key].instance_class
  kms_key_id                          = lookup(local.microservice_postgres_replica[each.key], "storage_encrypted", false) == true ? module.cmk.kms_keys[lookup(local.microservice_postgres_replica[each.key], "kms_key", "rds-cmk")].arn : null
  maintenance_window                  = "Sun:04:00-Sun:04:30" # UTC
  parameter_group_name                = try(local.microservice_postgres_replica[each.key].parameter_group, aws_db_parameter_group.microservice_parameter_group[each.key].name)
  performance_insights_enabled        = tobool(lookup(local.microservice_postgres_replica[each.key], "performance_insights", false))
  performance_insights_kms_key_id     = lookup(local.microservice_postgres_replica[each.key], "performance_insights", false) == true ? module.cmk.kms_keys[lookup(local.microservice_postgres_replica[each.key], "kms_key", "rds-cmk")].arn : null
  port                                = 5432
  replicate_source_db                 = aws_db_instance.microservice_postgres[each.key].identifier
  skip_final_snapshot                 = true
  storage_encrypted                   = lookup(local.microservice_postgres[each.key], "storage_encrypted", true)
  vpc_security_group_ids              = [local.security_groups.postgres.id]

  tags = merge(local.common_tags, {
    "Name"         = "${aws_db_instance.microservice_postgres[each.key].identifier}-replica-${local.microservice_postgres_replica[each.key].index}"
    "Microservice" = each.key
  })
}

resource "aws_db_parameter_group" "microservice_parameter_group" {
  for_each = local.microservice_postgres
  name     = try(local.microservice_postgres[each.key].parameter_group, format("%s-%s", "${local.prefix_dash}${each.key}-service", each.value.family))
  family   = lookup(each.value, "family")
  dynamic "parameter" {
    for_each = concat(try(each.value.parameters, []), local.postgres_default_override_parameters)
    content {
      name         = try(parameter.value.name, null)
      value        = try(parameter.value.value, null)
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }
  tags = merge(local.common_tags, {
    "Name"         = try(local.microservice_postgres[each.key].parameter_group, format("%s-%s", "${local.prefix_dash}${each.key}-service", each.value.family))
    "Microservice" = each.key
  })
}

resource "aws_route53_record" "microservice_postgres_record" {
  for_each = local.microservice_postgres

  zone_id = local.private_hosted_zones["${var.env}-internal.com"].zone_id
  name    = "${local.prefix_dash}${each.key}-service-postgres"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.microservice_postgres[each.key].address]
}
