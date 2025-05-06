terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider removed - using provider from root module

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 3)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"
  count   = var.create_vpc ? 1 : 0

  name = "vault-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  create_igw         = true
  enable_dns_support = true

  manage_default_network_acl    = true
  manage_default_route_table    = true
  manage_default_security_group = true

  tags = {
    Environment = var.environment
    Project     = "Vault"
  }
}
