output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "master_user_secret_arn" {
  description = "ARN of the RDS master user secret"
  value       = aws_secretsmanager_secret.db_master.arn
}

output "master_user_secret_name" {
  description = "Name of the RDS master user secret"
  value       = aws_secretsmanager_secret.db_master.name
}