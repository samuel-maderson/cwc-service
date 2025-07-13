terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
}

module "alb" {
  source = "./modules/alb"

  alb_name          = var.alb_name
  target_group_name = var.target_group_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name        = var.cluster_name
  task_family         = var.task_family
  container_name      = var.container_name
  container_image     = var.container_image
  service_name        = var.service_name
  container_port      = var.container_port
  cpu                 = var.cpu
  memory              = var.memory
  desired_count       = var.desired_count
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  aws_region          = var.aws_region
  target_group_arn    = module.alb.target_group_arn
  ecr_repository_name = var.ecr_repository_name
}

module "servicemanager" {
  source = "./modules/servicemanager"

  rds_master_user_secret_arn = module.rds.master_user_secret_arn
}

module "bastion" {
  source = "./modules/bastion"

  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "rds" {
  source = "./modules/rds"

  cluster_name            = var.cluster_name
  cluster_identifier      = var.rds_cluster_identifier
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  ecs_security_group_id   = module.ecs.security_group_id
  bastion_security_group_id = module.bastion.security_group_id
  db_subnet_group_name    = var.db_subnet_group_name
}