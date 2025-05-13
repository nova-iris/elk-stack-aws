# AWS Configuration
variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "access_key" {
  description = "AWS access key"
  type        = string
}

variable "secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# VPC Configuration
variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "Existing VPC ID if create_vpc is false"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "existing_public_subnets" {
  description = "List of existing public subnet IDs"
  type        = list(string)
  default     = []
}

variable "existing_private_subnets" {
  description = "List of existing private subnet IDs"
  type        = list(string)
  default     = []
}

# EC2 Configuration
variable "instance_name" {
  description = "Name of EC2 instance"
  type        = string
  default     = "elasticsearch-node"
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t3.2xlarge"
}

variable "instance_count" {
  description = "Number of Elasticsearch instances to create"
  type        = number
  default     = 3
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address"
  type        = bool
  default     = true
}

variable "public_key" {
  description = "Path to public key for SSH access"
  type        = string
  default     = ""
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 100
}

# Elasticsearch Configuration
variable "elasticsearch_version" {
  description = "Elasticsearch version to install"
  type        = string
  default     = "8.18.0"
}

variable "cluster_name" {
  description = "Elasticsearch cluster name"
  type        = string
  default     = "es-poc"
}

variable "enable_ui" {
  description = "Whether to enable Elasticsearch UI (Kibana)"
  type        = bool
  default     = true
}

# Logstash Configuration
variable "logstash_instance_type" {
  description = "Type of EC2 instance for Logstash"
  type        = string
  default     = "t3.xlarge"
}

variable "logstash_instance_name" {
  description = "Name of Logstash EC2 instance"
  type        = string
  default     = "logstash-node"
}

variable "logstash_volume_size" {
  description = "Root volume size in GB for Logstash instance"
  type        = number
  default     = 50
}

# Filebeat Configuration
variable "filebeat_instance_type" {
  description = "Type of EC2 instance for Filebeat"
  type        = string
  default     = "t2.micro"
}

variable "filebeat_instance_name" {
  description = "Name of Filebeat EC2 instance"
  type        = string
  default     = "filebeat-node"
}

variable "filebeat_volume_size" {
  description = "Root volume size in GB for Filebeat instance"
  type        = number
  default     = 20
}

# S3 Backup Configuration
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
