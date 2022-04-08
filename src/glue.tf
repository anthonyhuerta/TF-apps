locals {
  glue_default_arguments = {
    "--extra-py-files" = "s3://womply-datalake-scripts/${var.env}/datalake-common-lib.zip"
    "--TempDir"        = "s3://womply-datalake-glue-working/${var.env}/"
    "--job-language"   = "python"
    "--womply_env"     = var.env
    "--database_name"  = "glue-catalog-database"
  }
  glue_iam_policy_arns = [
    "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceNotebookRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  db_subnet_id_by_az = {
    "us-west-2a" = local.subnets.database.ids[0],
    "us-west-2b" = local.subnets.database.ids[1],
    "us-west-2c" = local.subnets.database.ids[2]
  }
}

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    sid     = "GlueAssumeRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com", "lambda.amazonaws.com"]
    }
  }
}

#####
# AWS Secrets Manager
#####
module "glue_secret" {
  source                  = "./modules/secrets"
  secret_prefix           = "${local.slash_prefix}/apps/glue/jobs/shared/"
  secret_names            = { "DB_PASSWORD" : "" }
  recovery_window_in_days = 0
  additional_tags = merge(local.common_tags, {
    "Microservice" = "${local.slash_prefix}/apps/glue/jobs/shared/DB_PASSWORD"
  })
}

data "aws_secretsmanager_secret_version" "glue_db_password" {
  secret_id  = module.glue_secret.secrets["DB_PASSWORD"].id
  depends_on = [module.glue_secret]
}

#####
# IAM Role
#####
resource "aws_iam_role" "glue_datalake" {
  name               = "${local.prefix_dash}glue-datalake"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json
  tags = merge(local.common_tags, {
    Name = "${local.prefix_dash}glue-datalake"
  })
}

######
# IAM policy
######
resource "aws_iam_role_policy" "datalake_read_write" {
  name = "${local.prefix_dash}datalake-read-write"
  policy = templatefile("${path.root}/config/policies/iam-permissions/datalake_read_write_policy.json.tmpl", {
    buckets = [
      "womply-datalake-data",
      "womply-datalake-glue-working",
      "womply-datalake-scripts"
    ]
    env        = var.env
    region     = var.region
    account_id = local.account_id
    secrets    = ["/apps/glue/jobs/shared/"]
  })
  role       = aws_iam_role.glue_datalake.name
  depends_on = [aws_iam_role.glue_datalake]
}

resource "aws_iam_role_policy" "athena_query_execution_access" {
  name       = "${local.prefix_dash}athena-query-execution-access"
  policy     = file("${path.module}/config/policies/iam-permissions/athena_query_execution_access.json")
  role       = aws_iam_role.glue_datalake.name
  depends_on = [aws_iam_role.glue_datalake]
}

######
# IAM policy attachment
######

resource "aws_iam_role_policy_attachment" "glue_awsmanaged_policy_attachment" {
  count      = length(local.glue_iam_policy_arns)
  policy_arn = local.glue_iam_policy_arns[count.index]
  role       = aws_iam_role.glue_datalake.name
}

#####
# Glue
#####

resource "aws_glue_connection" "glue_connection" {
  for_each = { for connection in local.microservice_glue_connections : connection.name => connection }
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:${each.value.connection_properties["engine"]}://${each.value.connection_properties["host"]}:${each.value.connection_properties["port"]}/${each.value.connection_properties["name"]}"
    PASSWORD            = data.aws_secretsmanager_secret_version.glue_db_password.secret_string
    USERNAME            = try(each.value.connection_properties.user, "datalake${var.env}")
  }
  physical_connection_requirements {
    availability_zone      = try(each.value.connection_properties.availability_zone, "us-west-2a")
    security_group_id_list = [local.network_security_groups["glue"].id]
    subnet_id              = try(each.value.connection_properties.subnet_id, local.db_subnet_id_by_az[each.value.connection_properties.availability_zone], local.subnets.database.ids[0])
  }
  name        = "${local.prefix_dash}${each.key}"
  description = "The glue job connection for microservice: ${each.value.microservice_name}-service and db_name: ${each.value.connection_properties["name"]}"
  depends_on  = [data.aws_secretsmanager_secret_version.glue_db_password]
}

resource "aws_glue_catalog_database" "glue_catalog_database" {
  description = "Glue database to store the database metadata/schema"
  name        = "${local.prefix_dash}glue-catalog-database"
}

resource "aws_glue_crawler" "glue_crawler" {
  for_each      = { for crawler in local.microservice_glue_crawlers : crawler.name => crawler }
  description   = "Database crawler for microservice ${each.value.microservice_name}-service with associated connection ${aws_glue_connection.glue_connection[each.value.crawl_properties.connection_name].name}"
  database_name = aws_glue_catalog_database.glue_catalog_database.name
  name          = try(each.key, "${local.prefix_dash}datalake-${each.key}-service")
  role          = try(each.value.crawl_properties.role_arn, "arn:aws:iam::${local.account_id}:role/${local.prefix_dash}glue-datalake")
  schedule      = try(each.value.crawl_properties.trigger, null)
  table_prefix  = try(each.value.crawl_properties.table_prefix, null)
  lineage_configuration {
    crawler_lineage_settings = try(each.value.crawl_properties.crawler_lineage_settings, "DISABLE")
  }
  recrawl_policy {
    recrawl_behavior = try(each.value.crawl_properties.recrawl_behavior, "CRAWL_EVERYTHING")
  }
  jdbc_target {
    connection_name = aws_glue_connection.glue_connection[each.value.crawl_properties.connection_name].name
    path            = try(each.value.crawl_properties.include_path, null)
    exclusions      = try(each.value.crawl_properties.exclude_paths, [])
  }
  schema_change_policy {
    delete_behavior = "DELETE_FROM_DATABASE"
  }
}

resource "aws_glue_job" "glue_job" {
  for_each          = { for job in local.microservice_glue_jobs : job.name => job }
  description       = "Glue job to transport the data from RDS to S3 for microservice: ${each.value.microservice_name}-service with connection ${aws_glue_connection.glue_connection[each.value.properties.connection_name].name}"
  name              = try(each.value.name, "${local.prefix_dash}${each.value.microservice_name}-service")
  glue_version      = try(each.value.properties.glue_version, "2.0")
  role_arn          = try(each.value.properties.role_arn, "arn:aws:iam::${local.account_id}:role/${local.prefix_dash}glue-datalake")
  connections       = [aws_glue_connection.glue_connection[each.value.properties.connection_name].name]
  max_capacity      = try(each.value.properties.shell_type, null) == "pythonshell" ? try(each.value.properties.max_capacity) : null
  number_of_workers = try(each.value.properties.shell_type, null) == "pythonshell" ? null : try(each.value.properties.number_of_workers, "10")
  worker_type       = try(each.value.properties.shell_type, null) == "pythonshell" ? null : try(each.value.properties.worker_type, "G.1X")
  timeout           = try(each.value.properties.timeout, "2880")
  max_retries       = try(each.value.properties.max_retries, null)
  command {
    name            = try(each.value.properties.shell_type, null)
    script_location = try(each.value.properties.script_location, format("%s/%s", "s3://womply-datalake-scripts/${var.env}", replace("${each.key}_service.py", "-", "_")))
    python_version  = try(each.value.properties.python_version, "3")
  }
  default_arguments = try(each.value.properties.default_arguments, local.glue_default_arguments)
  tags = merge(local.common_tags, {
    Name = "${each.key}-service"
  })
}

resource "aws_glue_trigger" "glue_trigger" {
  for_each = { for trigger in local.microservice_glue_triggers : trigger.name => trigger }
  name     = "${local.prefix_dash}${each.key}"
  schedule = try(each.value.trigger_properties.schedule, null)
  type     = try(each.value.trigger_properties.type, "ON_DEMAND")
  dynamic "actions" {
    for_each = try(each.value.trigger_properties.actions, [])
    content {
      arguments    = try(actions.value.arguments, {})
      job_name     = try(actions.value.job_name, null)
      crawler_name = try(actions.value.crawler_name, null)
      timeout      = try(actions.value.timeout, null)
    }
  }
  dynamic "predicate" {
    for_each = try(each.value.trigger_properties.predicate, {})
    content {
      dynamic "conditions" {
        for_each = try(predicate.value.conditions, {})
        content {
          job_name         = try(conditions.value.job_name, null)
          state            = try(conditions.value.state, null)
          crawler_name     = try(conditions.value.crawler_name, null)
          crawl_state      = try(conditions.value.crawler_state, null)
          logical_operator = try(conditions.value.logical_operator, "EQUALS")
        }
      }
      logical = try(predicate.value.logical, "AND")
    }
  }
  tags = merge(local.common_tags, {
    Name = "${local.prefix_dash}${each.key}"
  })
  depends_on = [aws_glue_job.glue_job]
}
