resource "random_password" "amq_random_password" {
  for_each = local.microservice_amq

  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "amq_random_password" {
  for_each = local.microservice_amq

  name                    = "${local.slash_prefix}/amq_random_password"
  recovery_window_in_days = 0

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "amq_random_password" {
  for_each = local.microservice_amq

  secret_id     = aws_secretsmanager_secret.amq_random_password[each.key].id
  secret_string = random_password.amq_random_password[each.key].result

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_mq_configuration" "amq_configuration" {
  for_each = local.microservice_amq

  description    = "aws activeMQ Configuration"
  name           = "${var.env}-${each.value["name"]}"
  engine_type    = each.value["engine_type"]
  engine_version = each.value["engine_version"]

  data = file(each.value["configuration"])
}

resource "aws_mq_broker" "amq_broker" {
  for_each = local.microservice_amq

  broker_name         = each.value["name"]
  deployment_mode     = each.value["deployment_mode"]
  engine_type         = "ActiveMQ"
  engine_version      = each.value["engine_version"]
  host_instance_type  = each.value["host_instance_type"]
  publicly_accessible = false
  security_groups     = [local.security_groups.amq.id]
  subnet_ids          = [local.subnets.database.ids[0]]

  configuration {
    id = aws_mq_configuration.amq_configuration[each.key].id
  }
  user {
    username       = "${var.env}-${each.value["name"]}"
    password       = random_password.amq_random_password[each.key].result
    groups         = ["admin"]
    console_access = true
  }

  auto_minor_version_upgrade = lookup(each.value, "auto_minor_version_upgrade", true)

  logs {
    general = true
    audit   = false
  }

}
