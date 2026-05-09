terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "vault" {
  address = var.vault_address
}

# Pull DB password from Vault
data "vault_generic_secret" "db" {
  path = "secret/${var.environment}/database"
}

module "vpc" {
  source      = "./modules/vpc"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  azs         = var.azs
}

module "security_groups" {
  source      = "./modules/security_groups"
  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
  bastion_sg_id = module.vpc.bastion_sg_id
}

module "alb" {
  source           = "./modules/alb"
  project          = var.project
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnet_ids
  frontend_subnets = module.vpc.frontend_subnet_ids
  public_alb_sg_id = module.security_groups.public_alb_sg_id
  internal_alb_sg_id = module.security_groups.internal_alb_sg_id
}

module "asg" {
  source              = "./modules/asg"
  project             = var.project
  environment         = var.environment
  frontend_subnet_ids = module.vpc.frontend_subnet_ids
  backend_subnet_ids  = module.vpc.backend_subnet_ids
  frontend_sg_id      = module.security_groups.frontend_sg_id
  backend_sg_id       = module.security_groups.backend_sg_id
  frontend_tg_arn     = module.alb.frontend_tg_arn
  backend_tg_arn      = module.alb.backend_tg_arn
  instance_type       = var.instance_type
  key_name            = var.key_name
  ami_id              = var.ami_id
  frontend_min        = var.frontend_min
  frontend_max        = var.frontend_max
  backend_min         = var.backend_min
  backend_max         = var.backend_max
  internal_alb_dns    = module.alb.internal_alb_dns
}

module "rds" {
  source            = "./modules/rds"
  project           = var.project
  environment       = var.environment
  db_subnet_ids     = module.vpc.db_subnet_ids
  rds_sg_id         = module.security_groups.rds_sg_id
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = data.vault_generic_secret.db.data["password"]
  db_instance_class = var.db_instance_class
}
