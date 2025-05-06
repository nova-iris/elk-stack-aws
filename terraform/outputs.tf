output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "elasticsearch_instance_ids" {
  description = "IDs of the Elasticsearch instances"
  value       = aws_instance.elasticsearch[*].id
}

output "elasticsearch_private_ips" {
  description = "Private IP addresses of the Elasticsearch instances"
  value       = aws_instance.elasticsearch[*].private_ip
}

output "elasticsearch_public_ips" {
  description = "Public IP addresses of the Elasticsearch instances"
  value       = aws_instance.elasticsearch[*].public_ip
}

output "elasticsearch_endpoints" {
  description = "Elasticsearch endpoints"
  value       = formatlist("http://%s:9200", aws_instance.elasticsearch[*].public_ip)
}

output "ssh_to_elasticsearch" {
  description = "SSH commands to connect to the Elasticsearch instances"
  value       = formatlist("ssh ubuntu@%s", aws_instance.elasticsearch[*].public_ip)
}
