variable "bucket_name" {
  description = "Name of S3 bucket for Elasticsearch backups"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Whether to enable versioning on the bucket"
  type        = bool
  default     = false
}

variable "enable_lifecycle" {
  description = "Whether to enable lifecycle rules"
  type        = bool
  default     = true
}

variable "transition_to_ia_days" {
  description = "Number of days after which to transition objects to Standard-IA storage class"
  type        = number
  default     = 30
}

variable "transition_to_glacier_days" {
  description = "Number of days after which to transition objects to Glacier storage class"
  type        = number
  default     = 90
}

variable "expiration_days" {
  description = "Number of days after which to expire objects"
  type        = number
  default     = 365
}

variable "additional_tags" {
  description = "Additional tags to add to S3 resources"
  type        = map(string)
  default     = {}
}
