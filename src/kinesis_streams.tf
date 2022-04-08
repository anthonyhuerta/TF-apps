data "aws_iam_policy_document" "kinesis_firehose_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

locals {
  apigee_kinesis = {
    # values for the Apigee kinesis firehose stream
    kinesis_firehose_name = "${local.prefix_dash}apigee-api-stats"
    buffer_size           = 5
    buffer_interval       = 300
    prefix                = "Apigee/dt=!{timestamp:yyyy}-!{timestamp:MM}-!{timestamp:dd}/"                                                # The path/time format where the kinesis firehose will store api stats
    error_output_prefix   = "Apigee/error/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/!{firehose:error-output-type}" # The path/time format where kinesis errors are stored
    apigee_directory_path = "womply-datalake-data/${var.env}"
  }
}

#####
# Kinesis Firehose for Apigee Billing
#####

# https://www.terraform.io/docs/providers/aws/r/kinesis_firehose_delivery_stream.html

# Create a role for kinesis Apigee firehose
resource "aws_iam_role" "kinesis_firehose_apigee_api_stats" {
  name               = "${local.prefix_dash}kinesis-firehose-apigee-api-stats"
  assume_role_policy = data.aws_iam_policy_document.kinesis_firehose_assume_role.json
  tags = merge(local.common_tags, {
    "Name" = "${local.prefix_dash}kinesis-firehose-apigee-api-stats"
  })
}

# Create and attach a policy for capturing cloudwatch events
resource "aws_iam_role_policy" "kinesis_firehose_apigee_cloudwatch" {
  name = "${local.prefix_dash}kinesis-firehose-apigee-cloudwatch"
  role = aws_iam_role.kinesis_firehose_apigee_api_stats.name
  policy = templatefile("${path.module}/config/policies/iam-permissions/kinesisfirehose_cloudwatch_policy.json.tmpl", {
    account_id            = local.account_ids[var.env]
    kinesis_firehose_name = local.apigee_kinesis.kinesis_firehose_name
  })
}

# Create and Attach a policy to access/write to a bucket in old infra
resource "aws_iam_role_policy" "kinesis_firehose_apigee_access_bucket" {
  name = "kinesis-firehose-apigee-access-bucket"
  role = aws_iam_role.kinesis_firehose_apigee_api_stats.name
  policy = templatefile("${path.module}/config/policies/iam-permissions/s3_write_only_policy.json.tmpl", {
    directory_path = local.apigee_kinesis.apigee_directory_path
  })
}

# Create the kinesis firehose stream
resource "aws_kinesis_firehose_delivery_stream" "apigee_api_stats" {
  name        = local.apigee_kinesis.kinesis_firehose_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.kinesis_firehose_apigee_api_stats.arn
    bucket_arn          = var.legacy_datalake_bucket_arn
    prefix              = "${var.env}/${local.apigee_kinesis.prefix}"
    buffer_size         = local.apigee_kinesis.buffer_size
    buffer_interval     = local.apigee_kinesis.buffer_interval
    error_output_prefix = "${var.env}/${local.apigee_kinesis.error_output_prefix}"
  }
  tags = merge(local.common_tags, {
    "Name" = local.apigee_kinesis.kinesis_firehose_name
  })
}
