variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "service_name" {
  description = "ECS service name"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB (the part after the last colon)"
  type        = string
}

variable "db_instance_id" {
  description = "RDS instance identifier"
  type        = string
}

variable "rds_cluster_identifier" {
  description = "RDS cluster identifier"
  type        = string
}

variable "alert_email" {
  description = "Email address to send alerts to"
  type        = string
  default     = "samuel.maderson@gmail.com"
}