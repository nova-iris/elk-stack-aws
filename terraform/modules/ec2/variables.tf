variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

// AWS credentials removed - using provider from root module

variable "vpc_id" {
  description = "VPC ID from vpc-vault module"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID from vpc-vault module"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "vault-server"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "instance_state" {
  description = "EC2 instance state after provisioning"
  type        = string
  default     = "running"
}

variable "public_key" {
  description = "Public key for SSH access"
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address with the instance"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "security_group_name" {
  description = "Name for the security group"
  type        = string
  default     = "vault-sg"
}

variable "user_data" {
  description = "User data to pass to the instance. This should be prepared outside the module."
  type        = string
  default     = ""
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
  default     = []
}

variable "create_alb" {
  description = "Whether to create an ALB for Vault"
  type        = bool
  default     = false
}
