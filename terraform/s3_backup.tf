# S3 bucket for Elasticsearch backups
module "elasticsearch_backup" {
  source = "./modules/s3"
  count  = var.es_use_s3_backups ? 1 : 0

  bucket_name       = "${var.cluster_name}-${var.environment}-es-backups-${var.aws_account_id}"
  environment       = var.environment
  force_destroy     = var.es_backup_force_destroy
  enable_versioning = var.es_backup_enable_versioning

  # Lifecycle configuration
  enable_lifecycle           = var.es_backup_enable_lifecycle
  transition_to_ia_days      = var.es_backup_transition_to_ia_days
  transition_to_glacier_days = var.es_backup_transition_to_glacier_days
  expiration_days            = var.es_backup_expiration_days

  additional_tags = {
    ClusterName = var.cluster_name
    BackupType  = "Elasticsearch"
    Service     = "ELK"
  }
}


# IAM role for Elasticsearch to access S3
resource "aws_iam_role" "elasticsearch_backup_role" {
  count = var.es_use_s3_backups ? 1 : 0
  name  = "${var.environment}-elasticsearch-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    {
      Name        = "${var.environment}-elasticsearch-backup-role"
      Environment = var.environment
    }
  )
}

# IAM policy for S3 access
resource "aws_iam_policy" "elasticsearch_s3_policy" {
  count       = var.es_use_s3_backups ? 1 : 0
  name        = "${var.environment}-elasticsearch-s3-policy"
  description = "Policy allowing Elasticsearch to access S3 bucket for backups"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucketVersions"
        ]
        Effect   = "Allow"
        Resource = module.elasticsearch_backup[0].bucket_arn
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Effect   = "Allow"
        Resource = "${module.elasticsearch_backup[0].bucket_arn}/*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "elasticsearch_s3_attachment" {
  count      = var.es_use_s3_backups ? 1 : 0
  role       = aws_iam_role.elasticsearch_backup_role[0].name
  policy_arn = aws_iam_policy.elasticsearch_s3_policy[0].arn
}

# IAM instance profile for EC2
resource "aws_iam_instance_profile" "elasticsearch_profile" {
  count = var.es_use_s3_backups ? 1 : 0
  name  = "${var.environment}-elasticsearch-backup-profile"
  role  = aws_iam_role.elasticsearch_backup_role[0].name
}
