output "bucket_id" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.es_backup.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.es_backup.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.es_backup.bucket_regional_domain_name
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.elasticsearch_backup_role.arn
}

output "role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.elasticsearch_backup_role.name
}

output "instance_profile_arn" {
  description = "The ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.elasticsearch_profile.arn
}

output "instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = aws_iam_instance_profile.elasticsearch_profile.name
}
