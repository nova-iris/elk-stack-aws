# S3 bucket for Elasticsearch backups
module "elasticsearch_backup" {
  source = "./modules/s3"
  count  = var.es_use_s3_backups ? 1 : 0

  bucket_name       = "${var.cluster_name}-${var.environment}-es-backups"
  environment       = var.environment
  force_destroy     = var.es_backup_force_destroy
  enable_versioning = var.es_backup_enable_versioning

  # Lifecycle configuration
  enable_lifecycle           = var.es_backup_enable_lifecycle
  backup_prefix              = var.es_backup_prefix
  transition_to_ia_days      = var.es_backup_transition_to_ia_days
  transition_to_glacier_days = var.es_backup_transition_to_glacier_days
  expiration_days            = var.es_backup_expiration_days

  additional_tags = {
    ClusterName = var.cluster_name
    BackupType  = "Elasticsearch"
    Service     = "ELK"
  }
}
