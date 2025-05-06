# AWS Configuration
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
# variable "elasticsearch_version" {
#   description = "Elasticsearch version to install"
#   type        = string
#   default     = "7.10.2"
# }

variable "cluster_name" {
  description = "Elasticsearch cluster name"
  type        = string
  default     = "elk-cluster"
}

# variable "enable_ui" {
#   description = "Whether to enable Elasticsearch UI (Kibana)"
#   type        = bool
#   default     = true
# }
