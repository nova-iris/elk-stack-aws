terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# S3 bucket for Elasticsearch backups
resource "aws_s3_bucket" "es_backup" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(
    {
      Name        = var.bucket_name
      Environment = var.environment
      Role        = "elasticsearch-backup"
      ManagedBy   = "terraform"
    },
    var.additional_tags
  )
}

# S3 bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "es_backup" {
  bucket = aws_s3_bucket.es_backup.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 bucket access control (set to private)
resource "aws_s3_bucket_public_access_block" "es_backup" {
  bucket = aws_s3_bucket.es_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "es_backup" {
  bucket = aws_s3_bucket.es_backup.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "es_backup" {
  bucket = aws_s3_bucket.es_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "es_backup" {
  bucket = aws_s3_bucket.es_backup.id

  rule {
    id     = "backup-expiration"
    status = "Enabled"

    filter {
      prefix = var.backup_prefix
    }

    # Transition to Infrequent Access after 30 days (if enabled)
    dynamic "transition" {
      for_each = var.enable_lifecycle && var.transition_to_ia_days > 0 ? [1] : []
      content {
        days          = var.transition_to_ia_days
        storage_class = "STANDARD_IA"
      }
    }

    # Transition to Glacier after 90 days (if enabled)
    dynamic "transition" {
      for_each = var.enable_lifecycle && var.transition_to_glacier_days > 0 ? [1] : []
      content {
        days          = var.transition_to_glacier_days
        storage_class = "GLACIER"
      }
    }

    # Expire objects after the specified number of days (if enabled)
    dynamic "expiration" {
      for_each = var.enable_lifecycle && var.expiration_days > 0 ? [1] : []
      content {
        days = var.expiration_days
      }
    }
  }
}

# IAM role for Elasticsearch to access S3
resource "aws_iam_role" "elasticsearch_backup_role" {
  name = "${var.environment}-elasticsearch-backup-role"

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
    },
    var.additional_tags
  )
}

# IAM policy for S3 access
resource "aws_iam_policy" "elasticsearch_s3_policy" {
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
        Resource = aws_s3_bucket.es_backup.arn
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
        Resource = "${aws_s3_bucket.es_backup.arn}/*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "elasticsearch_s3_attachment" {
  role       = aws_iam_role.elasticsearch_backup_role.name
  policy_arn = aws_iam_policy.elasticsearch_s3_policy.arn
}

# IAM instance profile for EC2
resource "aws_iam_instance_profile" "elasticsearch_profile" {
  name = "${var.environment}-elasticsearch-backup-profile"
  role = aws_iam_role.elasticsearch_backup_role.name
}
