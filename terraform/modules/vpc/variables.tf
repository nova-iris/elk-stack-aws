variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

// AWS credentials removed - using provider from root module

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "Existing VPC ID (if create_vpc = false)"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "existing_public_subnets" {
  description = "List of existing public subnet IDs (if create_vpc = false)"
  type        = list(string)
  default     = []
}

variable "existing_private_subnets" {
  description = "List of existing private subnet IDs (if create_vpc = false)"
  type        = list(string)
  default     = []
}
