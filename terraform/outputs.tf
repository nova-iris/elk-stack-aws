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

# Elasticsearch outputs
output "elasticsearch_instance_ids" {
  description = "IDs of the Elasticsearch instances"
  value       = module.elasticsearch.instance_ids
}

output "elasticsearch_private_ips" {
  description = "Private IP addresses of the Elasticsearch instances"
  value       = module.elasticsearch.private_ips
}

output "elasticsearch_public_ips" {
  description = "Public IP addresses of the Elasticsearch instances"
  value       = module.elasticsearch.public_ips
}

output "elasticsearch_endpoints" {
  description = "Elasticsearch endpoints"
  value       = formatlist("http://%s:9200", module.elasticsearch.public_ips)
}

output "elasticsearch_security_group_id" {
  description = "ID of the Elasticsearch security group"
  value       = module.elasticsearch.security_group_id
}

output "ssh_to_elasticsearch" {
  description = "SSH commands to connect to the Elasticsearch instances"
  value       = formatlist("ssh ubuntu@%s", module.elasticsearch.public_ips)
}

# Logstash outputs
output "logstash_instance_id" {
  description = "ID of the Logstash instance"
  value       = module.logstash.instance_id
}

output "logstash_private_ip" {
  description = "Private IP address of the Logstash instance"
  value       = module.logstash.private_ip
}

output "logstash_public_ip" {
  description = "Public IP address of the Logstash instance"
  value       = module.logstash.public_ip
}

output "logstash_security_group_id" {
  description = "ID of the Logstash security group"
  value       = module.logstash.security_group_id
}

output "ssh_to_logstash" {
  description = "SSH command to connect to the Logstash instance"
  value       = var.associate_public_ip_address ? "ssh ubuntu@${module.logstash.public_ip}" : "ssh ubuntu@${module.logstash.private_ip}"
}

# Filebeat outputs
output "filebeat_instance_id" {
  description = "ID of the Filebeat instance"
  value       = module.filebeat.instance_id
}

output "filebeat_private_ip" {
  description = "Private IP address of the Filebeat instance"
  value       = module.filebeat.private_ip
}

output "filebeat_public_ip" {
  description = "Public IP address of the Filebeat instance"
  value       = module.filebeat.public_ip
}

output "filebeat_security_group_id" {
  description = "ID of the Filebeat security group"
  value       = module.filebeat.security_group_id
}

output "ssh_to_filebeat" {
  description = "SSH command to connect to the Filebeat instance"
  value       = var.associate_public_ip_address ? "ssh ubuntu@${module.filebeat.public_ip}" : "ssh ubuntu@${module.filebeat.private_ip}"
}
