output "api_url" {
  description = "URL to access the Vehicle Catalog API"
  value       = "http://${module.alb.alb_dns_name}"
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
  value       = module.rds.db_endpoint
}