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

output "logstash_instance_id" {
  description = "ID of the Logstash instance"
  value       = aws_instance.logstash.id
}

output "logstash_private_ip" {
  description = "Private IP address of the Logstash instance"
  value       = aws_instance.logstash.private_ip
}

output "logstash_public_ip" {
  description = "Public IP address of the Logstash instance"
  value       = aws_instance.logstash.public_ip
}

output "ssh_to_logstash" {
  description = "SSH command to connect to the Logstash instance"
  value       = "ssh ubuntu@${aws_instance.logstash.public_ip}"
}

output "filebeat_instance_id" {
  description = "ID of the Filebeat instance"
  value       = aws_instance.filebeat.id
}

output "filebeat_private_ip" {
  description = "Private IP address of the Filebeat instance"
  value       = aws_instance.filebeat.private_ip
}

output "filebeat_public_ip" {
  description = "Public IP address of the Filebeat instance"
  value       = aws_instance.filebeat.public_ip
}

output "ssh_to_filebeat" {
  description = "SSH command to connect to the Filebeat instance"
  value       = "ssh ubuntu@${aws_instance.filebeat.public_ip}"
}
