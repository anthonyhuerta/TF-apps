output "kms_keys" {
  value = {
    for k, v in var.kms_key_configs.kms_keys :
    k => {
      arn   = aws_kms_key.this[k].arn
      alias = aws_kms_alias.this[k].name
    }
  }
}
