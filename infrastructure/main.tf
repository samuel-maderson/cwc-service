terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
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

module "s3" {
  source = "./modules/s3"

  bucket_name = "cwc-vehicle-images-${random_id.bucket_suffix.hex}"
}

module "api_auth" {
  source = "./modules/api_auth"

  environment = var.environment
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
}

module "iam" {
  source = "./modules/iam"

  cluster_name   = var.cluster_name
  s3_bucket_arn  = module.s3.bucket_arn
  secret_arn     = var.environment == "dev" ? module.rds_dev[0].master_user_secret_arn : module.rds[0].master_user_secret_arn
}

module "alb" {
  count  = var.environment == "prod" ? 1 : 0
  source = "./modules/alb"

  alb_name          = var.alb_name
  target_group_name = var.target_group_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ecs" {
  count  = var.environment == "prod" ? 1 : 0
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
  target_group_arn    = module.alb[0].target_group_arn
  ecr_repository_name = var.ecr_repository_name
  s3_bucket_arn       = module.s3.bucket_arn
  secret_arn          = module.rds[0].master_user_secret_arn
  api_auth_secret_name = module.api_auth.secret_name
  environment         = var.environment
  rds_endpoint        = module.rds[0].db_endpoint
  secret_name         = module.rds[0].master_user_secret_name
  s3_bucket_name      = module.s3.bucket_name
  ecr_repository_url  = module.ecr.repository_url
}

module "bastion" {
  count  = var.environment == "prod" ? 1 : 0
  source = "./modules/bastion"

  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "rds_dev" {
  count  = var.environment == "dev" ? 1 : 0
  source = "./modules/rds_dev"

  cluster_name         = var.cluster_name
  cluster_identifier   = var.rds_cluster_identifier
  database_name        = var.database_name
  master_username      = var.master_username
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  db_subnet_group_name = var.db_subnet_group_name
}

module "rds" {
  count  = var.environment == "prod" ? 1 : 0
  source = "./modules/rds"

  cluster_name            = var.cluster_name
  cluster_identifier      = var.rds_cluster_identifier
  database_name           = var.database_name
  master_username         = var.master_username
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  ecs_security_group_id   = module.ecs[0].security_group_id
  bastion_security_group_id = module.bastion[0].security_group_id
  db_subnet_group_name    = var.db_subnet_group_name
}



