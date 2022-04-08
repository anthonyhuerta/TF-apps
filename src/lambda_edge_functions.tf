data "aws_iam_policy_document" "lambda_edge_function_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    # The aws_iam_role’s assume role policy must include both lambda.amazonaws.com and edgelambda.amazonaws.com
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-permissions.html
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
  }
}

# Create a role for lamdba edge function
resource "aws_iam_role" "cloudfront_lambda_edge" {
  name               = "${local.prefix_dash}lambda-edge"
  assume_role_policy = data.aws_iam_policy_document.lambda_edge_function_role.json
  tags = merge(local.common_tags, {
    "Name" = "${local.prefix_dash}lambda-edge-role"
  })
}

resource "aws_cloudwatch_log_group" "cloudfront_lambda_edge" {
  for_each = local.lambda_final_functions

  name = each.key
  tags = merge(local.common_tags, {
    "Name" = "${local.prefix_dash}lambda-edge-log-group"
  })
}

# Create and attach a policy for capturing cloudwatch events and logging
resource "aws_iam_role_policy" "cloudfront_lambda_edge" {
  name   = "${local.prefix_dash}cloudfront-lambda-edge"
  role   = aws_iam_role.cloudfront_lambda_edge.name
  policy = file("${path.module}/config/policies/iam-permissions/cloudfront_lambda_policy.json")
}

data "archive_file" "lambda_source" {
  for_each = local.lambda_final_functions

  type        = try(each.value.type, "zip")
  source_file = try(each.value.source_file, "")
  output_path = try(each.value.output_path, "")
}

resource "aws_lambda_function" "cloudfront_lambda_edge" {
  for_each = local.lambda_final_functions

  provider         = aws.useast1
  filename         = data.archive_file.lambda_source[each.key].output_path
  function_name    = each.key
  role             = aws_iam_role.cloudfront_lambda_edge.arn
  handler          = try(each.value.handler, "index.handler")
  source_code_hash = filebase64sha256(data.archive_file.lambda_source[each.key].output_path)
  runtime          = try(each.value.runtime, null)

  # The referred object doesn't exist so i updated it.
  depends_on = [aws_iam_role_policy.cloudfront_lambda_edge]
  publish    = try(each.value.publish, true)
  tags = merge(local.common_tags, {
    "Name" = "${local.prefix_dash}filename"
  })
}
