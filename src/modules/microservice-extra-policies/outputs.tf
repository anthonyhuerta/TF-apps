output "policies" {
  description = "The Terraform resource associated with the created IAM policy"
  value       = aws_iam_policy.this
}
