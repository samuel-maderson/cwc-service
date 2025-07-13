variable "cluster_name" {
  description = "Name prefix for resources"
  type        = string
}

variable "cluster_identifier" {
  description = "RDS cluster identifier"
  type        = string
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for RDS"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}