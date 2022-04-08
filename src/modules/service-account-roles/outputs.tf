output "policy" {
  description = "The Terraform resource associated with the created IAM policy"
  value       = aws_iam_policy.this
}

output "role" {
  description = "The Terraform resource associated with the created IAM role"
  value       = aws_iam_role.this
}
