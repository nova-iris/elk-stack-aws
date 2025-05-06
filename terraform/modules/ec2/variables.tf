variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

// AWS credentials removed - using provider from root module

variable "vpc_id" {
  description = "VPC ID where EC2 instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 instance will be deployed"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "ec2-instance"
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

variable "ami_id" {
  description = "AMI ID to use for the instance. If not provided, latest Ubuntu 24.04 will be used."
  type        = string
  default     = ""
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
  default     = "ec2-sg"
}

variable "user_data" {
  description = "User data to pass to the instance. This should be prepared outside the module."
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional tags to add to the instance and security group"
  type        = map(string)
  default     = {}
}

variable "custom_ingress_rules" {
  description = "List of custom ingress rules for the security group in addition to SSH, HTTP, and HTTPS"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "enable_default_ingress_rules" {
  description = "Whether to enable default ingress rules (SSH, HTTP, HTTPS)"
  type        = bool
  default     = true
}

variable "root_volume_type" {
  description = "Type of the root volume (gp2, gp3, io1, io2, etc.)"
  type        = string
  default     = "gp2"
}

variable "delete_on_termination" {
  description = "Whether to delete the root volume on instance termination"
  type        = bool
  default     = false
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "use_num_suffix" {
  description = "Whether to append a numerical suffix to instance names when creating multiple instances"
  type        = bool
  default     = true
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to use for the instance"
  type        = string
  default     = null
}
