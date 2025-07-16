output "secret_name" {
  description = "Name of the API auth secret"
  value       = aws_secretsmanager_secret.api_auth.name
}

output "secret_arn" {
  description = "ARN of the API auth secret"
  value       = aws_secretsmanager_secret.api_auth.arn
}