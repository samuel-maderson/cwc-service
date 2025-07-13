output "api_url" {
  description = "URL to access the Vehicle Catalog API"
  value       = var.environment == "prod" ? "http://${module.alb[0].alb_dns_name}" : null
}

output "bastion_instance_name" {
  description = "Name of the bastion host instance"
  value       = "${var.cluster_name}-bastion"
}

output "rds_secret_name" {
  description = "Name of the RDS master user secret"
  value       = "rds-db-credentials/${var.rds_cluster_identifier}/master"
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = var.environment == "prod" ? module.rds[0].db_endpoint : null
}

output "rds_dev_endpoint" {
  description = "RDS dev instance endpoint"
  value       = var.environment == "dev" ? module.rds_dev[0].db_endpoint : null
}

output "rds_dev_secret_name" {
  description = "Name of the RDS dev master user secret"
  value       = var.environment == "dev" ? module.rds_dev[0].master_user_secret_name : null
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for vehicle images"
  value       = module.s3.bucket_name
}

output "app_role_arn" {
  description = "ARN of the application IAM role"
  value       = module.iam.app_role_arn
}