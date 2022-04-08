locals {
  prefix_dash = var.prefix == "" ? "" : "${var.prefix}-"
}

resource "aws_elasticsearch_domain" "this" {
  for_each = toset(var.clusters)

  # Domain length is limited to 28 characters max
  domain_name           = "${local.prefix_dash}${var.elasticsearch_conf.name}-${each.key}"
  elasticsearch_version = try(var.elasticsearch_conf.version, "7.10")
  cluster_config {
    instance_count           = tonumber(try(var.elasticsearch_conf.instance_count, 3))
    instance_type            = try(var.elasticsearch_conf.instance_type, "r5.large.elasticsearch")
    dedicated_master_enabled = tobool(try(var.elasticsearch_conf.master_enabled, false))
    dedicated_master_count   = tonumber(try(var.elasticsearch_conf.master_count, 0))
    zone_awareness_enabled   = true
    zone_awareness_config {
      availability_zone_count = 3
    }
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  ebs_options {
    ebs_enabled = true
    volume_size = tonumber(try(var.elasticsearch_conf.ebs_volume_size, 20))
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  tags = merge(var.additional_tags, {
    Name = "${local.prefix_dash}${var.elasticsearch_conf.name}-${each.key}"
  })
}

resource "aws_elasticsearch_domain_policy" "this" {
  for_each    = toset(var.clusters)
  domain_name = aws_elasticsearch_domain.this[each.key].domain_name

  access_policies = templatefile("${path.root}/config/policies/service-access/microservice_elasticsearch.json.tmpl", try({
    account_ids  = var.account_ids
    resource_arn = aws_elasticsearch_domain.this[each.key].arn
  }, {}))
}
