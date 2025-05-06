output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = var.create_vpc ? module.vpc[0].private_subnets : var.existing_private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = var.create_vpc ? module.vpc[0].public_subnets : var.existing_public_subnets
}
