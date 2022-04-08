#######
# KMS
# This module will be used to provision customer-managed-key(CMK) KMS.
#######

locals {
  prefix_dash  = var.prefix == "" ? "" : "${var.prefix}-"
  slash_prefix = var.prefix == "" ? "" : "/${var.prefix}"
}

resource "aws_kms_key" "this" {
  for_each                 = var.kms_key_configs.kms_keys
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Customer managed KMS key ${each.key}"
  key_usage                = "ENCRYPT_DECRYPT"
  policy                   = templatefile("${path.root}/config/policies/iam-permissions/${try(each.value.policy_template, "") == "" ? "kms_default_key_policy.json.tmpl" : each.value.policy_template}", { params = try(each.value.policy_params, {}), account_id = var.account_id, aws_resource_name = each.value.aws_resource_name, region = var.region })
  deletion_window_in_days  = try(each.value.deletion_window_in_days, "30")
  is_enabled               = "true"
  enable_key_rotation      = try(each.value.enable_key_rotation, "false")
  tags                     = var.tags
}

resource "aws_kms_alias" "this" {
  for_each      = var.kms_key_configs.kms_keys
  name          = "alias/${local.prefix_dash}${each.key}"
  target_key_id = aws_kms_key.this[each.key].id
  depends_on    = [aws_kms_key.this]
}
