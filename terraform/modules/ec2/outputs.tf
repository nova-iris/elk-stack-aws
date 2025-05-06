output "vault_instance_id" {
  description = "ID of the Vault EC2 instance"
  value       = module.vault_server.id
}

output "vault_private_ip" {
  description = "Private IP address of the Vault instance"
  value       = module.vault_server.private_ip
}

output "vault_public_ip" {
  description = "Public IP address of the Vault instance (if applicable)"
  value       = var.associate_public_ip_address ? module.vault_server.public_ip : null
}

output "vault_endpoint" {
  description = "Vault API endpoint"
  value       = var.create_alb && length(var.public_subnet_ids) > 0 ? "http://${aws_lb.vault_alb[0].dns_name}:8200" : (var.associate_public_ip_address ? "http://${module.vault_server.public_ip}:8200" : "http://${module.vault_server.private_ip}:8200")
}
