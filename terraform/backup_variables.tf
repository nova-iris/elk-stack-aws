# S3 backup configuration variables
variable "es_use_s3_backups" {
  description = "Whether to enable S3 backups for Elasticsearch"
  type        = bool
  default     = true
}

variable "es_backup_force_destroy" {
  description = "Whether to force destroy the backup bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "es_backup_enable_versioning" {
  description = "Whether to enable versioning on the backup bucket"
  type        = bool
  default     = false
}

variable "es_backup_enable_lifecycle" {
  description = "Whether to enable lifecycle rules for backup objects"
  type        = bool
  default     = true
}

variable "es_backup_prefix" {
  description = "Prefix for backup objects in the bucket"
  type        = string
  default     = "elasticsearch/"
}

variable "es_backup_transition_to_ia_days" {
  description = "Number of days after which to transition backup objects to Standard-IA storage class"
  type        = number
  default     = 30
}

variable "es_backup_transition_to_glacier_days" {
  description = "Number of days after which to transition backup objects to Glacier storage class"
  type        = number
  default     = 90
}

variable "es_backup_expiration_days" {
  description = "Number of days after which to expire backup objects"
  type        = number
  default     = 365
}
