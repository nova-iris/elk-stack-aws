output "instance_ids" {
  description = "List of IDs of all EC2 instances"
  value       = module.ec2_instance[*].id
}

output "instance_id" {
  description = "ID of the first EC2 instance (for backward compatibility)"
  value       = var.instance_count > 0 ? module.ec2_instance[0].id : null
}

output "private_ips" {
  description = "List of private IP addresses of all EC2 instances"
  value       = module.ec2_instance[*].private_ip
}

output "private_ip" {
  description = "Private IP address of the first EC2 instance (for backward compatibility)"
  value       = var.instance_count > 0 ? module.ec2_instance[0].private_ip : null
}

output "public_ips" {
  description = "List of public IP addresses of all EC2 instances (if applicable)"
  value       = var.associate_public_ip_address ? module.ec2_instance[*].public_ip : null
}

output "public_ip" {
  description = "Public IP address of the first EC2 instance (for backward compatibility)"
  value       = var.associate_public_ip_address && var.instance_count > 0 ? module.ec2_instance[0].public_ip : null
}

output "security_group_id" {
  description = "ID of the security group attached to the instances"
  value       = aws_security_group.instance_sg.id
}

output "security_group_name" {
  description = "Name of the security group attached to the instances"
  value       = aws_security_group.instance_sg.name
}

output "instance_arns" {
  description = "List of ARNs of all EC2 instances"
  value       = module.ec2_instance[*].arn
}

output "primary_network_interface_ids" {
  description = "List of primary network interface IDs of all EC2 instances"
  value       = module.ec2_instance[*].primary_network_interface_id
}

output "instance_count" {
  description = "Number of EC2 instances created"
  value       = var.instance_count
}
