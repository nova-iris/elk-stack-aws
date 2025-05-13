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
