locals {
  prefix_dash  = var.prefix == "" ? "" : "${var.prefix}-"
  slash_prefix = var.prefix == "" ? "" : "/${var.prefix}"
}

resource "aws_iam_policy" "this" {
  name        = var.iam_policy_name != "" ? var.iam_policy_name : "${local.prefix_dash}eks-${var.cluster_name}-${var.namespace}-${var.service_account_names[0]}"
  path        = var.iam_policy_path
  description = var.iam_policy_description != "" ? var.iam_policy_description : "For Kubernetes ServiceAccount sa/${var.service_account_names[0]} in namespace ${var.namespace}"

  policy = var.iam_policy_json

  tags = merge(var.additional_tags, {
    "Name"                 = var.iam_policy_name != "" ? var.iam_policy_name : "${local.prefix_dash}eks-${var.cluster_name}-${var.namespace}-${var.service_account_names[0]}"
    "Cluster"              = var.cluster_name
    "Kubernetes:Kind"      = "ServiceAccount"
    "Kubernetes:Namespace" = var.namespace
  })
}

resource "aws_iam_role" "this" {
  name        = var.iam_role_name != "" ? var.iam_role_name : "${local.prefix_dash}eks-${var.cluster_name}-${var.namespace}-${var.service_account_names[0]}"
  path        = var.iam_role_path
  description = var.iam_role_description != "" ? var.iam_role_description : "Kubernetes ServiceAccount sa/${var.service_account_names[0]} in namespace ${var.namespace}"

  assume_role_policy = templatefile("${path.module}/files/assume-eks-service-accounts-role.json.tmpl", {
    oidc_provider_arn     = var.oidc_provider_arn
    oidc_provider_url     = var.oidc_provider_url
    namespace             = var.namespace
    service_account_names = sort(distinct(var.service_account_names))
  })

  tags = merge(var.additional_tags, {
    "Name"                 = var.iam_role_name != "" ? var.iam_role_name : "${local.prefix_dash}eks-${var.cluster_name}-${var.namespace}-${var.service_account_names[0]}"
    "Cluster"              = var.cluster_name
    "Kubernetes:Kind"      = "ServiceAccount"
    "Kubernetes:Namespace" = var.namespace
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
