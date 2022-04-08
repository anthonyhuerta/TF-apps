# Terraform will create and manage everything EXCEPT the value of the secret, which we will update manually
resource "aws_secretsmanager_secret" "this" {
  for_each = var.secret_names

  name        = "${var.secret_prefix}${each.key}"
  description = try(each.value.description, "") != "" ? each.value.description : null

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(try(var.additional_tags, {}), try(each.value.additional_tags, {}), {
    Name = "${var.secret_prefix}${each.key}"
  })
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each      = var.secret_names
  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = "PLACEHOLDER"
  lifecycle {
    ignore_changes = [secret_string]
  }
}
