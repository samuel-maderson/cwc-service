variable "cluster_name" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where bastion will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for bastion"
  type        = list(string)
}