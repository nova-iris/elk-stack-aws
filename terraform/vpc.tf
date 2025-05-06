# VPC Module
module "vpc" {
  source = "./modules/vpc"

  # VPC specific variables
  environment              = var.environment
  create_vpc               = var.create_vpc
  vpc_id                   = var.vpc_id
  vpc_cidr                 = var.vpc_cidr
  existing_public_subnets  = var.existing_public_subnets
  existing_private_subnets = var.existing_private_subnets
}
