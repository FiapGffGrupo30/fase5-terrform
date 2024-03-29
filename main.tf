terraform {
  required_version = ">=0.13.1"
  required_providers {
    aws   = ">=5.22.0"
    local = ">=2.4.0"
  }
  # Salvando o tfstate no Bucket S3 para evitarmos quebrar
  # o tfstate ao trabalharmos em grupos/squads.
  # OBS 1: Se faz necessário criar o Buckt S3 antes de executar
  # esse trechode código.
  # OBS 2: Ao criar o S3 deixar abilitado o auto versionamento a
  # cada alteração.
  backend "s3" {
    bucket = "bucket-cluster-gff"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "new-vpc" {
  source         = "./modules/vpc"
  prefix         = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}

module "security-group" {
  source = "./modules/security_group"
  vpc_id = module.new-vpc.vpc_id
}

//module "target-group" {
//  source = "./modules/target_group"
//  vpc_id = module.new-vpc.vpc_id
//}

module "load_balance" {
  source            = "./modules/load_balance"
  vpc_id            = module.new-vpc.vpc_id
  security_group_id = module.security-group.security_group_id
  public_subnet_ids = module.new-vpc.public_subnet_ids
  prefix            = var.prefix
  selected_subnets  = var.selected_subnets
}

module "ecr_repository" {
  source                         = "./modules/ecr"
  ecr_repository_name_requests   = var.ecr_repository_name_requests
  ecr_repository_name_payments   = var.ecr_repository_name_payments
  ecr_repository_name_users      = var.ecr_repository_name_users
  //ecr_repository_name_products   = var.ecr_repository_name_products
}

module "ecs_fargate" {
  source                 = "./modules/ecs_fg"
  subnets                = module.new-vpc.public_subnet_ids
  security_group_id      = module.security-group.security_group_id
  task_family            = var.task_family
  task_cpu               = var.task_cpu
  task_memory            = var.task_memory
  cluster_name           = var.cluster_name
  service_name           = var.service_name
  ecs_service_requests   = var.ecs_service_requests
  ecs_service_payments   = var.ecs_service_payments
  ecs_service_users      = var.ecs_service_users
  //ecs_service_products   = var.ecs_service_products
}

//module "eks" {
//  source         = "./modules/eks"
//  prefix         = var.prefix
//  vpc_id         = module.new-vpc.vpc_id
//  cluster_name   = var.cluster_name
//  retention_days = var.retention_days
//  subnet_ids     = module.new-vpc.subnet_ids
//  desired_size   = var.desired_size
//  max_size       = var.max_size
//  min_size       = var.min_size
//}
//
//module "cognito" {
//  source = "./modules/cognito"
//}
//
//module "api_gateway" {
//  source      = "./modules/api_gateway"
//  name        = "${var.prefix}-api-gateway"
//  description = "API Gateway for ${var.prefix}"
//}