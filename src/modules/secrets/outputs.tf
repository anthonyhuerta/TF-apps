output "secrets" {
  description = "The ARN and name for each of the created secrets"
  value = {
    for k, v in aws_secretsmanager_secret.this :
    k => {
      id   = v.id
      arn  = v.arn
      name = v.name
    }
  }
}
