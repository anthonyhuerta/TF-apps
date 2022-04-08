output "citus_key_pair_fingerprint" {
  description = "AWS Key Pair Fingerprint used for citus instances"
  value       = aws_key_pair.citus.fingerprint
}

output "citus_key_pair_name" {
  description = "AWS Key Pair Name used for citus instances"
  value       = aws_key_pair.citus.key_name
}

output "citus_key_private_pem" {
  description = "Private SSH key for citus instances in PEM format"
  value       = tls_private_key.citus.private_key_pem
  sensitive   = true
}

output "citus_key_public_openssh" {
  description = "Public SSH key for citus instances in OpenSSH authorized_keys format"
  value       = tls_private_key.citus.public_key_openssh
}

output "cloudfront_distributions" {
  description = "Cloudfront distributions created by this root module"
  value       = aws_cloudfront_distribution.common
}

output "microservice_alerts" {
  description = "Information on microservice ownership and alerting information"
  value = {
    for k, v in local.microservice_configs :
    k => {
      pagerduty_enabled = lookup(v, "pagerduty_enabled", false)
      slack_channel     = lookup(v, "slack_channel", "")
      team              = v.team
    }
  }
}

output "microservice_citus" {
  description = "EC2 instances owned by citus"
  value = {
    for k, v in local.microservice_citus :
    k => {
      instance_id          = module.microservice_citus[k].id
      instance_private_ip  = module.microservice_citus[k].private_ip
      instance_private_dns = module.microservice_citus[k].private_dns
    }
  }
}

output "microservice_eks_service_account_roles" {
  description = "IAM roles used by Microservices' Kubernetes ServiceAccounts"
  value = {
    for k, v in aws_iam_role.microservice_eks_service_accounts :
    k => {
      arn  = v.arn
      name = v.name
      # create_date        = v.create_date
      # description        = v.description
      # id                 = v.id
      # path               = v.path
      # assume_role_policy = v.assume_role_policy
    }
  }
}

output "microservice_postgres" {
  description = "Postgres database owned by microservices"
  value = {
    for k, v in local.microservice_postgres :
    k => {
      address  = aws_db_instance.microservice_postgres[k].address
      arn      = aws_db_instance.microservice_postgres[k].arn
      id       = aws_db_instance.microservice_postgres[k].id
      endpoint = aws_db_instance.microservice_postgres[k].endpoint
      name     = aws_db_instance.microservice_postgres[k].name
      fqdn     = aws_route53_record.microservice_postgres_record[k].fqdn
      critical = {
        slack_channel             = try(local.microservice_postgres[k].critical.slack_channel, "alerts-infra-critical")
        cpu_threshold             = try(local.microservice_postgres[k].critical.cpu_threshold, 90)
        free_memory_threshold     = try(local.microservice_postgres[k].critical.free_memory_threshold, 265000000)
        read_latency_threshold    = try(local.microservice_postgres[k].critical.read_latency_threshold, "0.03")
        replication_lag_threshold = try(local.microservice_postgres[k].critical.replication_lag_threshold, 240)
        storage_threshold         = try(local.microservice_postgres[k].critical.storage_threshold, 90)
        write_latency_threshold   = try(local.microservice_postgres[k].critical.write_latency_threshold, "0.3")
      }
      warning = {
        slack_channel             = try(local.microservice_postgres[k].warning.slack_channel, "alerts-infra-warning")
        cpu_threshold             = try(local.microservice_postgres[k].warning.cpu_threshold, 80)
        free_memory_threshold     = try(local.microservice_postgres[k].warning.free_memory_threshold, 305000000)
        read_latency_threshold    = try(local.microservice_postgres[k].warning.read_latency_threshold, "0.025")
        replication_lag_threshold = try(local.microservice_postgres[k].warning.replication_lag_threshold, 180)
        storage_threshold         = try(local.microservice_postgres[k].warning.storage_threshold, 80)
        write_latency_threshold   = try(local.microservice_postgres[k].warning.write_latency_threshold, "0.2")
      }
    }
  }
}

output "microservice_postgres_replica" {
  description = "Postgres database owned by microservices"
  value = {
    for k, v in local.microservice_postgres_replica :
    k => {
      address  = aws_db_instance.microservice_postgres_replica[k].address
      arn      = aws_db_instance.microservice_postgres_replica[k].arn
      id       = aws_db_instance.microservice_postgres_replica[k].id
      endpoint = aws_db_instance.microservice_postgres_replica[k].endpoint
      name     = aws_db_instance.microservice_postgres_replica[k].name
    }
  }
}

output "microservice_queues" {
  description = "Queues owned by microservices"
  value = {
    for k, v in local.microservice_queues :
    k => {
      dlq = {
        arn                       = aws_sqs_queue.microservice_dlq[k].arn
        id                        = aws_sqs_queue.microservice_dlq[k].id
        message_retention_seconds = aws_sqs_queue.microservice_dlq[k].message_retention_seconds
        name                      = aws_sqs_queue.microservice_dlq[k].name
        team                      = local.microservice_configs[k].team
        size_critical             = lookup(local.microservice_queues[k].dlq, "size_critical", 1)
      }
      medium = {
        arn                       = aws_sqs_queue.microservice_medium[k].arn
        id                        = aws_sqs_queue.microservice_medium[k].id
        name                      = aws_sqs_queue.microservice_medium[k].name
        message_retention_seconds = aws_sqs_queue.microservice_medium[k].message_retention_seconds
        team                      = local.microservice_configs[k].team
        age_critical              = lookup(local.microservice_queues[k].medium, "age_critical", 300)
        size_critical             = lookup(local.microservice_queues[k].medium, "size_critical", 100)
      }
    }
  }
}

output "microservice_redis_cache" {
  description = "Redis clusters used for caching by microservices"
  value = {
    for k, v in local.microservice_redis_cache :
    k => {
      id                       = aws_elasticache_replication_group.microservice_redis_cache[k].id
      primary_endpoint_address = aws_elasticache_replication_group.microservice_redis_cache[k].primary_endpoint_address
    }
  }
}

output "microservice_redis_sidekiq" {
  description = "Redis clusters used for Sidekiq queues by microservices"
  value = {
    for k, v in local.microservice_redis_sidekiq :
    k => {
      id                       = aws_elasticache_replication_group.microservice_redis_sidekiq[k].id
      primary_endpoint_address = aws_elasticache_replication_group.microservice_redis_sidekiq[k].primary_endpoint_address
    }
  }
}

output "microservice_secrets" {
  description = "The ARN and name of secrets added to AWS Secrets Manager for each microservice"
  value       = { for k, v in module.microservice_secrets : k => v.secrets }
}

output "microservice_elasticsearch" {
  description = "The ARN and name of secrets added to AWS Secrets Manager for each microservice"
  value       = { for k, v in module.microservice_elasticsearch : k => v.microservice_elasticsearch }
}

output "monitor_kubernetes_apps" {
  description = "A map of apps running on Kubernetes and the associated parameters used for monitoring"
  value       = local.microservice_kubernetes
}

output "topics" {
  description = "All SNS topics managed via this root module"
  value = {
    for k, v in aws_sns_topic.all :
    v.name => {
      arn  = v.arn
      name = v.name
    }
  }
}

output "glue_jobs" {
  description = "Glue jobs created for microservices"
  value = {
    for k, v in aws_glue_job.glue_job :
    k => {
      arn : v.arn
      name : v.id
    }
  }
}

output "kms_keys" {
  value = module.cmk.kms_keys
}

output "app_secrets" {
  description = "The ARN and name of secrets added to AWS Secrets Manager for each apps"
  value       = { for k, v in module.app_secrets : k => v.secrets }
}
