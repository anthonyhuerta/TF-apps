resource "aws_iam_policy" "this" {
  for_each = var.policies

  name        = "${var.role_name}-${replace(each.key, "_", "-")}"
  description = try(each.value.description, null)
  policy      = templatefile("${path.root}/config/policies/iam-permissions/${each.value.policy_template}", try(each.value.params, {}))

  tags = merge(var.additional_tags, {
    Name = "${var.role_name}-${replace(each.key, "_", "-")}"
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.policies

  role       = var.role_name
  policy_arn = aws_iam_policy.this[each.key].arn
}
