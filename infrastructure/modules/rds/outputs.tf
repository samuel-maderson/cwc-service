output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_address" {
  description = "RDS instance address"
  value       = aws_db_instance.main.address
}

output "db_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "master_user_secret_arn" {
  description = "ARN of the RDS master user secret"
  value       = aws_secretsmanager_secret.db_master.arn
}

output "master_user_secret_name" {
  description = "Name of the RDS master user secret"
  value       = aws_secretsmanager_secret.db_master.name
}