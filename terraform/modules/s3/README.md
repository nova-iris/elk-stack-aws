# S3 Backup Module for Elasticsearch

This module provides an S3 bucket configured for Elasticsearch snapshot backups along with the necessary IAM roles and policies.

## Features

- Creates an S3 bucket optimized for Elasticsearch backups
- Configures security settings (private access, encryption)
- Sets up IAM roles and policies for EC2 instance access to S3
- Implements lifecycle policies for cost-effective data storage
- Optionally configures versioning, transitions to cheaper storage classes

## Usage Example

```hcl
module "elasticsearch_backup_bucket" {
  source = "../modules/s3"
  
  bucket_name      = "my-company-es-backups"
  environment      = "prod"
  enable_lifecycle = true
  
  # Lifecycle configuration
  transition_to_ia_days      = 30
  transition_to_glacier_days = 90
  expiration_days            = 365
  
  additional_tags = {
    Project     = "ELK Stack"
    BackupType  = "Elasticsearch"
  }
}

# Update elasticsearch module to use the IAM instance profile
module "elasticsearch" {
  source = "./modules/ec2"
  
  # existing configuration...
  
  # Add this line to enable S3 backup access:
  iam_instance_profile = module.elasticsearch_backup_bucket.instance_profile_name
}
```

## Integration with Elasticsearch

After deploying this module, you need to:

1. Configure an Elasticsearch repository that points to the S3 bucket
2. Set up backup schedules using Elasticsearch API or management tools

The IAM role permissions enable Elasticsearch to:
- List the bucket contents
- Upload snapshot files
- Retrieve existing snapshots
- Delete old snapshots

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of S3 bucket for Elasticsearch backups | string | - | yes |
| environment | Environment name (dev, prod, etc.) | string | "dev" | no |
| force_destroy | Whether to force destroy bucket even if it contains objects | bool | false | no |
| enable_versioning | Whether to enable versioning on the bucket | bool | false | no |
| enable_lifecycle | Whether to enable lifecycle rules | bool | true | no |
| backup_prefix | Prefix for backup objects in the bucket | string | "es-backup/" | no |
| transition_to_ia_days | Days after which to transition to Standard-IA storage | number | 30 | no |
| transition_to_glacier_days | Days after which to transition to Glacier storage | number | 90 | no |
| expiration_days | Days after which to expire objects | number | 365 | no |
| additional_tags | Additional tags to add to S3 resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the S3 bucket |
| bucket_arn | The ARN of the S3 bucket |
| bucket_domain_name | The bucket domain name |
| role_arn | The ARN of the IAM role |
| role_name | The name of the IAM role |
| instance_profile_arn | The ARN of the IAM instance profile |
| instance_profile_name | The name of the IAM instance profile |
